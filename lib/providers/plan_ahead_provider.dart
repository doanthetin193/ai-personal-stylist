import 'package:flutter/foundation.dart';

import '../models/clothing_item.dart';
import '../models/plan_ahead.dart';
import '../models/weather.dart';
import '../services/firebase_service.dart';
import '../services/groq_service.dart';
import '../services/weather_service.dart';
import '../utils/constants.dart';
import 'wardrobe_provider.dart';

enum PlanAheadStatus { initial, loading, loaded, error }

class PlanAheadProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final WeatherService _weatherService;
  final GroqService _groqService;

  PlanAheadStatus _status = PlanAheadStatus.initial;
  final List<SmartOutfitPlan> _plans = [];
  final List<String> _pendingNotifications = [];
  bool _isCreatingPlan = false;
  bool _isRefreshingPlan = false;
  String? _errorMessage;

  PlanAheadProvider(
    this._firebaseService,
    this._weatherService,
    this._groqService,
  );

  PlanAheadStatus get status => _status;
  List<SmartOutfitPlan> get plans => List.unmodifiable(_plans);
  bool get isLoading => _status == PlanAheadStatus.loading;
  bool get isCreatingPlan => _isCreatingPlan;
  bool get isRefreshingPlan => _isRefreshingPlan;
  String? get errorMessage => _errorMessage;

  List<String> consumeNotifications() {
    final copy = List<String>.from(_pendingNotifications);
    _pendingNotifications.clear();
    return copy;
  }

  Future<void> loadPlans({required WardrobeProvider wardrobeProvider}) async {
    try {
      _status = PlanAheadStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final fetched = await _firebaseService.getUserPlanAheadPlans();
      _plans
        ..clear()
        ..addAll(fetched);
      _sortPlans();

      _status = PlanAheadStatus.loaded;
      notifyListeners();

      await _runAutoUpdatesIfNeeded(wardrobeProvider: wardrobeProvider);
    } catch (e) {
      _status = PlanAheadStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createPlan({
    required DateTime eventDateTime,
    required String location,
    required PlanActivityType activityType,
    String? customActivity,
    String? dressCode,
    required WardrobeProvider wardrobeProvider,
  }) async {
    if (_firebaseService.currentUser == null) {
      _errorMessage = 'Bạn cần đăng nhập trước khi tạo kế hoạch.';
      notifyListeners();
      return false;
    }

    final now = DateTime.now();
    if (eventDateTime.isBefore(now)) {
      _errorMessage = 'Thời gian sự kiện phải ở tương lai.';
      notifyListeners();
      return false;
    }

    final eventDay = DateTime(
      eventDateTime.year,
      eventDateTime.month,
      eventDateTime.day,
    );
    final nowDay = DateTime(now.year, now.month, now.day);
    final daysAhead = eventDay.difference(nowDay).inDays;
    if (daysAhead > AppConstants.maxForecastDaysAhead) {
      _errorMessage =
          'Hiện chỉ hỗ trợ forecast tối đa ${AppConstants.maxForecastDaysAhead} ngày tới.';
      notifyListeners();
      return false;
    }

    try {
      _isCreatingPlan = true;
      _errorMessage = null;
      notifyListeners();

      final plan = await _buildPlan(
        planId: '',
        eventDateTime: eventDateTime,
        location: location,
        activityType: activityType,
        customActivity: customActivity,
        dressCode: dressCode,
        wardrobeProvider: wardrobeProvider,
        existingCreatedAt: null,
        completedCheckpoints: const [],
        autoCheckpointLabel: null,
        adjustmentReason: null,
      );

      if (plan == null) {
        _isCreatingPlan = false;
        notifyListeners();
        return false;
      }

      final createdId = await _firebaseService.createPlanAheadPlan(plan);
      if (createdId == null) {
        _errorMessage = 'Không thể lưu kế hoạch. Vui lòng thử lại.';
        _isCreatingPlan = false;
        notifyListeners();
        return false;
      }

      _plans.add(plan.copyWith(id: createdId));
      _sortPlans();
      _pendingNotifications.add(
        'Đã tạo kế hoạch outfit cho ${plan.eventLabel}.',
      );

      _isCreatingPlan = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isCreatingPlan = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> refreshPlanById({
    required String planId,
    required WardrobeProvider wardrobeProvider,
    bool isAuto = false,
    String? autoCheckpoint,
  }) async {
    final index = _plans.indexWhere((p) => p.id == planId);
    if (index == -1) return false;

    final current = _plans[index];

    try {
      _isRefreshingPlan = true;
      _errorMessage = null;
      notifyListeners();

      final mergedCheckpoints = Set<String>.from(
        current.completedAutoCheckpoints,
      );
      if (autoCheckpoint != null && autoCheckpoint.isNotEmpty) {
        mergedCheckpoints.add(autoCheckpoint);
      }

      final refreshed = await _buildPlan(
        planId: current.id,
        eventDateTime: current.eventDateTime,
        location: current.location,
        activityType: current.activityType,
        customActivity: current.customActivity,
        dressCode: current.dressCode,
        wardrobeProvider: wardrobeProvider,
        existingCreatedAt: current.createdAt,
        completedCheckpoints: mergedCheckpoints.toList(),
        autoCheckpointLabel: autoCheckpoint,
        adjustmentReason: _detectForecastChangeReason(
          oldForecast: current.forecastSnapshot,
          newForecast: null,
        ),
      );

      if (refreshed == null) {
        _isRefreshingPlan = false;
        notifyListeners();
        return false;
      }

      final forecastChangeReason = _detectForecastChangeReason(
        oldForecast: current.forecastSnapshot,
        newForecast: refreshed.forecastSnapshot,
      );

      final finalRefreshed = refreshed.copyWith(
        needsAdjustment: forecastChangeReason != null,
        adjustmentReason: forecastChangeReason,
        completedAutoCheckpoints: mergedCheckpoints.toList(),
        lastAutoUpdateCheckpoint: autoCheckpoint,
        lastAutoUpdatedAt: isAuto ? DateTime.now() : current.lastAutoUpdatedAt,
      );

      final saved = await _firebaseService.updatePlanAheadPlan(
        planId,
        finalRefreshed.toJson(),
      );

      if (!saved) {
        _errorMessage = 'Không thể cập nhật kế hoạch. Vui lòng thử lại.';
        _isRefreshingPlan = false;
        notifyListeners();
        return false;
      }

      _plans[index] = finalRefreshed;
      _sortPlans();

      if (isAuto) {
        if (forecastChangeReason != null) {
          _pendingNotifications.add(
            'Kế hoạch ${finalRefreshed.eventLabel} đã tự cập nhật ($autoCheckpoint): $forecastChangeReason',
          );
        } else {
          _pendingNotifications.add(
            'Kế hoạch ${finalRefreshed.eventLabel} đã tự cập nhật ($autoCheckpoint).',
          );
        }
      } else {
        _pendingNotifications.add(
          'Đã cập nhật kế hoạch ${finalRefreshed.eventLabel} theo forecast mới nhất.',
        );
      }

      _isRefreshingPlan = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isRefreshingPlan = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlan(String planId) async {
    final success = await _firebaseService.deletePlanAheadPlan(planId);
    if (!success) return false;

    _plans.removeWhere((plan) => plan.id == planId);
    notifyListeners();
    return true;
  }

  Future<void> _runAutoUpdatesIfNeeded({
    required WardrobeProvider wardrobeProvider,
  }) async {
    if (_plans.isEmpty) return;

    for (final plan in List<SmartOutfitPlan>.from(_plans)) {
      final checkpoint = _getDueAutoCheckpoint(plan);
      if (checkpoint == null) continue;

      await refreshPlanById(
        planId: plan.id,
        wardrobeProvider: wardrobeProvider,
        isAuto: true,
        autoCheckpoint: checkpoint,
      );
    }
  }

  String? _getDueAutoCheckpoint(SmartOutfitPlan plan) {
    final now = DateTime.now();
    final event = plan.eventDateTime;

    // Không chạy auto-update cho sự kiện đã qua quá nửa ngày.
    if (now.isAfter(event.add(const Duration(hours: 12)))) {
      return null;
    }

    final done = plan.completedAutoCheckpoints.toSet();
    final isSameDay =
        now.year == event.year &&
        now.month == event.month &&
        now.day == event.day;

    if (isSameDay && now.hour >= 6 && !done.contains('day_morning')) {
      return 'day_morning';
    }

    if (now.isAfter(event.subtract(const Duration(days: 1))) &&
        !done.contains('t_minus_1')) {
      return 't_minus_1';
    }

    if (now.isAfter(event.subtract(const Duration(days: 3))) &&
        !done.contains('t_minus_3')) {
      return 't_minus_3';
    }

    return null;
  }

  Future<SmartOutfitPlan?> _buildPlan({
    required String planId,
    required DateTime eventDateTime,
    required String location,
    required PlanActivityType activityType,
    required String? customActivity,
    required String? dressCode,
    required WardrobeProvider wardrobeProvider,
    required DateTime? existingCreatedAt,
    required List<String> completedCheckpoints,
    required String? autoCheckpointLabel,
    required String? adjustmentReason,
  }) async {
    final forecast = await _weatherService.getForecastForDate(
      targetDate: eventDateTime,
      city: location,
    );

    if (forecast == null) {
      _errorMessage =
          'Không lấy được forecast cho ngày đã chọn. Vui lòng chọn ngày trong ${AppConstants.maxForecastDaysAhead} ngày tới.';
      return null;
    }

    final suggestionWardrobe = wardrobeProvider.getSuggestionWardrobe();
    if (suggestionWardrobe.isEmpty) {
      _errorMessage = 'Tủ đồ trống, chưa thể tạo kế hoạch outfit.';
      return null;
    }

    final options = await _generatePlanOptions(
      wardrobeProvider: wardrobeProvider,
      wardrobe: suggestionWardrobe,
      forecast: forecast,
      activityType: activityType,
      customActivity: customActivity,
      dressCode: dressCode,
    );

    if (options.length < 2) {
      _errorMessage = 'Không đủ dữ liệu để tạo phương án chính và dự phòng.';
      return null;
    }

    final now = DateTime.now();
    final userId = _firebaseService.currentUser?.uid ?? '';

    return SmartOutfitPlan(
      id: planId,
      userId: userId,
      eventDateTime: eventDateTime,
      location: location,
      activityType: activityType,
      customActivity: customActivity,
      dressCode: dressCode,
      forecastSnapshot: PlanForecastSnapshot.fromForecastInfo(forecast),
      options: options,
      prepChecklist: _buildPrepChecklist(
        forecast: forecast,
        options: options,
        wardrobe: wardrobeProvider.allItems,
        eventDateTime: eventDateTime,
      ),
      needsAdjustment: adjustmentReason != null,
      adjustmentReason: adjustmentReason,
      completedAutoCheckpoints: completedCheckpoints,
      lastAutoUpdateCheckpoint: autoCheckpointLabel,
      lastAutoUpdatedAt: autoCheckpointLabel != null ? now : null,
      createdAt: existingCreatedAt ?? now,
      updatedAt: now,
    );
  }

  Future<List<PlannedOutfitOption>> _generatePlanOptions({
    required WardrobeProvider wardrobeProvider,
    required List<ClothingItem> wardrobe,
    required ForecastInfo forecast,
    required PlanActivityType activityType,
    required String? customActivity,
    required String? dressCode,
  }) async {
    final occasion = _buildOccasion(
      activityType: activityType,
      customActivity: customActivity,
      dressCode: dressCode,
    );

    final scenarios = _buildScenarios(forecast);
    final options = <PlannedOutfitOption>[];

    for (final scenario in scenarios) {
      final suggestion = await _groqService.suggestOutfit(
        wardrobe: wardrobe,
        weatherContext: scenario['weatherContext']!,
        occasion: '$occasion (${scenario['title']})',
        stylePreference: wardrobeProvider.stylePreferenceAiDescription,
        genderProfile: wardrobeProvider.genderProfileAiDescription,
        styleProfile: wardrobeProvider.styleProfileAiDescription,
      );

      if (suggestion == null) {
        continue;
      }

      final outfit = wardrobeProvider.buildPlanningOutfitFromSuggestion(
        suggestion,
        '${activityType.displayName} - ${scenario['title']}',
      );

      options.add(
        PlannedOutfitOption.fromOutfit(
          key: scenario['key']!,
          title: scenario['title']!,
          scenarioNote: scenario['note']!,
          outfit: outfit,
        ),
      );
    }

    return options;
  }

  List<Map<String, String>> _buildScenarios(ForecastInfo forecast) {
    final baseWeatherContext = forecast.toAIDescription();
    final tempBackupNote = forecast.avgTemp >= 29
        ? 'Dự phòng khi trời nóng hơn dự báo.'
        : 'Dự phòng khi trời lạnh hơn dự báo.';

    final tempBackupContext = forecast.avgTemp >= 29
        ? '$baseWeatherContext\nBackup scenario: Assume temperature increases by +4°C, prioritize breathable fabrics and less layers.'
        : '$baseWeatherContext\nBackup scenario: Assume temperature drops by -4°C, prioritize layering and protective outerwear.';

    return [
      {
        'key': 'primary',
        'title': 'Phương án chính',
        'note': 'Phù hợp forecast hiện tại',
        'weatherContext': baseWeatherContext,
      },
      {
        'key': 'rain_backup',
        'title': 'Dự phòng mưa',
        'note': 'Dùng khi trời chuyển mưa hoặc gió mạnh',
        'weatherContext':
            '$baseWeatherContext\nBackup scenario: sudden rain, stronger wind, prioritize water-friendly layers and footwear.',
      },
      {
        'key': 'temp_backup',
        'title': 'Dự phòng nhiệt độ',
        'note': tempBackupNote,
        'weatherContext': tempBackupContext,
      },
    ];
  }

  String _buildOccasion({
    required PlanActivityType activityType,
    required String? customActivity,
    required String? dressCode,
  }) {
    final customActivityPart =
        (customActivity == null || customActivity.trim().isEmpty)
        ? ''
        : ', hoạt động cụ thể: ${customActivity.trim()}';
    final dressCodePart = (dressCode == null || dressCode.trim().isEmpty)
        ? ''
        : ', dress code: ${dressCode.trim()}';
    return 'Kế hoạch sự kiện ${activityType.displayName}$customActivityPart$dressCodePart';
  }

  List<String> _buildPrepChecklist({
    required ForecastInfo forecast,
    required List<PlannedOutfitOption> options,
    required List<ClothingItem> wardrobe,
    required DateTime eventDateTime,
  }) {
    final checklist = <String>[
      'Chuẩn bị outfit từ tối hôm trước để tránh thiếu món vào phút cuối.',
      'Kiểm tra và là phẳng các món đồ trong phương án chính.',
    ];

    if (forecast.rainProbability >= 0.4) {
      checklist.add('Khả năng mưa cao, chuẩn bị ô hoặc áo mưa gọn nhẹ.');
    }

    if (forecast.minTemp < 22 &&
        options.every((o) => o.outerwearId == null || o.outerwearId!.isEmpty)) {
      checklist.add('Forecast có thể se lạnh, cân nhắc thêm áo khoác nhẹ.');
    }

    if (forecast.maxTemp > 32) {
      checklist.add(
        'Nhiệt độ cao, ưu tiên chất liệu thoáng mát và thấm hút tốt.',
      );
    }

    if (forecast.daysAhead >= 5) {
      checklist.add('Dự báo còn biến động, nên bấm cập nhật lại gần ngày đi.');
    }

    final missing = <String>{};
    final primary = options.firstOrNull;
    if (primary != null) {
      if (primary.topId == null || primary.topId!.isEmpty) missing.add('áo');
      if (primary.bottomId == null || primary.bottomId!.isEmpty) {
        missing.add('quần/chân váy');
      }
      if (primary.footwearId == null || primary.footwearId!.isEmpty) {
        missing.add('giày');
      }
    }

    if (missing.isNotEmpty) {
      checklist.add(
        'Tủ đồ đang thiếu ${missing.join(', ')} cho phương án chính, nên chuẩn bị thêm để tránh bị động.',
      );
    }

    final idSet = <String>{
      ...options.map((o) => o.topId).whereType<String>(),
      ...options.map((o) => o.bottomId).whereType<String>(),
      ...options.map((o) => o.outerwearId).whereType<String>(),
      ...options.map((o) => o.footwearId).whereType<String>(),
      ...options.expand((o) => o.accessoryIds),
    };

    final selectedItems = wardrobe
        .where((item) => idSet.contains(item.id))
        .toList();
    for (final item in selectedItems) {
      if (item.lastWorn == null) continue;
      final diffDays = eventDateTime.difference(item.lastWorn!).inDays;
      if (diffDays <= 1) {
        checklist.add(
          'Món ${item.type.displayName} (${item.color}) vừa mặc gần đây, nhớ giặt/làm mới trước ngày đi.',
        );
      }
    }

    return checklist.toSet().toList();
  }

  String? _detectForecastChangeReason({
    required PlanForecastSnapshot oldForecast,
    required PlanForecastSnapshot? newForecast,
  }) {
    if (newForecast == null) return null;

    final reasons = <String>[];

    final oldAvg = (oldForecast.minTemp + oldForecast.maxTemp) / 2;
    final newAvg = (newForecast.minTemp + newForecast.maxTemp) / 2;
    final tempDiff = (newAvg - oldAvg).abs();
    if (tempDiff >= 3.5) {
      reasons.add(
        'nhiệt độ trung bình đổi khoảng ${tempDiff.toStringAsFixed(1)}°C',
      );
    }

    final rainDiff = (newForecast.rainProbability - oldForecast.rainProbability)
        .abs();
    if (rainDiff >= 0.25) {
      final oldPct = (oldForecast.rainProbability * 100).round();
      final newPct = (newForecast.rainProbability * 100).round();
      reasons.add('xác suất mưa đổi mạnh từ $oldPct% lên $newPct%');
    }

    final oldRainy = oldForecast.description.toLowerCase().contains('rain');
    final newRainy = newForecast.description.toLowerCase().contains('rain');
    if (oldRainy != newRainy) {
      reasons.add(
        'trạng thái thời tiết chuyển đổi sang ${newForecast.description}',
      );
    }

    final windDiff = (newForecast.windSpeed - oldForecast.windSpeed).abs();
    if (windDiff >= 3) {
      reasons.add('gió thay đổi đáng kể (${windDiff.toStringAsFixed(1)} m/s)');
    }

    if (reasons.isEmpty) return null;
    return 'Forecast đã thay đổi: ${reasons.join('; ')}.';
  }

  void _sortPlans() {
    _plans.sort((a, b) => a.eventDateTime.compareTo(b.eventDateTime));
  }
}
