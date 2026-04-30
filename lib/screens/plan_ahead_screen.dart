import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/clothing_item.dart';
import '../models/plan_ahead.dart';
import '../providers/plan_ahead_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class PlanAheadScreen extends StatefulWidget {
  const PlanAheadScreen({super.key});

  @override
  State<PlanAheadScreen> createState() => _PlanAheadScreenState();
}

class _PlanAheadScreenState extends State<PlanAheadScreen> {
  static const List<String> _quickCities = [
    'Quy Nhon',
    'Ho Chi Minh City',
    'Ha Noi',
    'Da Nang',
  ];

  static const List<String> _dressCodePresets = [
    'Casual',
    'Smart casual',
    'Business casual',
    'Business formal',
    'Black tie',
    'Sporty',
  ];

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _customActivityController =
      TextEditingController();
  final TextEditingController _dressCodeController = TextEditingController();

  DateTime? _eventDateTime;
  PlanActivityType _activityType = PlanActivityType.leisure;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final wardrobe = context.read<WardrobeProvider>();
      _locationController.text =
          wardrobe.weather?.cityName ?? AppConstants.defaultCity;

      final planProvider = context.read<PlanAheadProvider>();
      await planProvider.loadPlans(wardrobeProvider: wardrobe);
      _showPendingMessages(planProvider);
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _customActivityController.dispose();
    _dressCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Smart Plan Ahead'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<PlanAheadProvider, WardrobeProvider>(
        builder: (context, planner, wardrobe, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await planner.loadPlans(wardrobeProvider: wardrobe);
              _showPendingMessages(planner);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildIntroCard(),
                const SizedBox(height: 16),
                _buildCreatePlanCard(planner, wardrobe),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kế hoạch đã tạo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (planner.isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (planner.plans.isEmpty)
                  _buildEmptyPlans()
                else
                  ...planner.plans.map(
                    (plan) => _buildPlanCard(
                      planner: planner,
                      wardrobe: wardrobe,
                      plan: plan,
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECFEFF), Color(0xFFEFF6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lên kế hoạch outfit trước sự kiện',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Tính năng này dùng forecast theo ngày để tạo phương án chính + dự phòng mưa + dự phòng nhiệt độ, và tự cập nhật ở mốc T-3, T-1, sáng ngày đi.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePlanCard(
    PlanAheadProvider planner,
    WardrobeProvider wardrobe,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tạo kế hoạch mới',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildDateTimeSelector(),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Địa điểm (thành phố)',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickCities
                .map(
                  (city) => ActionChip(
                    label: Text(city),
                    onPressed: () => _locationController.text = city,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PlanActivityType>(
            initialValue: _activityType,
            decoration: const InputDecoration(
              labelText: 'Loại hoạt động',
              prefixIcon: Icon(Icons.event_note_outlined),
            ),
            items: PlanActivityType.values
                .map(
                  (activity) => DropdownMenuItem(
                    value: activity,
                    child: Text(activity.displayName),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _activityType = value);
              }
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PlanActivityType.values
                .map(
                  (activity) => ChoiceChip(
                    label: Text(activity.displayName),
                    selected: _activityType == activity,
                    onSelected: (_) => setState(() => _activityType = activity),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customActivityController,
            decoration: const InputDecoration(
              labelText: 'Hoạt động cụ thể (tuỳ chọn)',
              hintText: 'Ví dụ: Họp khách hàng, đám cưới ngoài trời...',
              prefixIcon: Icon(Icons.edit_note_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dressCodeController,
            decoration: const InputDecoration(
              labelText: 'Dress code (tuỳ chọn)',
              prefixIcon: Icon(Icons.style_outlined),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dressCodePresets
                .map(
                  (preset) => ActionChip(
                    label: Text(preset),
                    onPressed: () => _dressCodeController.text = preset,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          if (planner.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                planner.errorMessage!,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: planner.isCreatingPlan
                  ? null
                  : () => _createPlan(planner, wardrobe),
              icon: planner.isCreatingPlan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                planner.isCreatingPlan
                    ? 'Đang tạo kế hoạch...'
                    : 'Tạo kế hoạch outfit',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    final label = _eventDateTime == null
        ? 'Chọn ngày giờ sự kiện'
        : _formatDateTime(_eventDateTime!);

    return InkWell(
      onTap: _pickDateTime,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Ngày giờ sự kiện',
          prefixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlans() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        children: [
          Icon(Icons.schedule, size: 40, color: AppTheme.textSecondary),
          SizedBox(height: 10),
          Text(
            'Chưa có kế hoạch nào',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Tạo kế hoạch để chuẩn bị outfit trước ngày đi.',
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required PlanAheadProvider planner,
    required WardrobeProvider wardrobe,
    required SmartOutfitPlan plan,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.eventLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.activityType.displayName} • ${plan.location}',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    if (plan.customActivity != null &&
                        plan.customActivity!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Chi tiết: ${plan.customActivity}',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    if (plan.dressCode != null && plan.dressCode!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Dress code: ${plan.dressCode}',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Cập nhật theo dự báo mới',
                onPressed: planner.isRefreshingPlan
                    ? null
                    : () async {
                        await planner.refreshPlanById(
                          planId: plan.id,
                          wardrobeProvider: wardrobe,
                        );
                        _showPendingMessages(planner);
                      },
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Xoá kế hoạch',
                onPressed: () => _confirmDeletePlan(planner, plan.id),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildForecastSummary(plan),
          if (plan.needsAdjustment &&
              plan.adjustmentReason != null &&
              plan.adjustmentReason!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Cần điều chỉnh: ${plan.adjustmentReason}',
                style: const TextStyle(color: Color(0xFF9A5A00)),
              ),
            ),
          ],
          if (plan.lastAutoUpdateCheckpoint != null) ...[
            const SizedBox(height: 8),
            Text(
              'Đã tự cập nhật mốc: ${_checkpointDisplay(plan.lastAutoUpdateCheckpoint!)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Text(
            'Phương án outfit',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...plan.options.map(
            (option) => _buildOptionCard(option, wardrobe.allItems),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nhắc chuẩn bị',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...plan.prepChecklist.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSummary(SmartOutfitPlan plan) {
    final snapshot = plan.forecastSnapshot;
    final rainPct = (snapshot.rainProbability * 100).round();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          Text(
            'Nhiệt độ: ${snapshot.minTemp.round()}-${snapshot.maxTemp.round()}°C',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text('Mưa: $rainPct%'),
          Text('Gió: ${snapshot.windSpeed.toStringAsFixed(1)} m/s'),
          Text('Độ ẩm: ${snapshot.humidity}%'),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    PlannedOutfitOption option,
    List<ClothingItem> wardrobe,
  ) {
    final items = _resolveOptionItems(option, wardrobe);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            option.scenarioNote,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            option.reason,
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text('Không đủ item cụ thể trong tủ đồ cho phương án này.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        '${item.type.displayName} (${item.color})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  List<ClothingItem> _resolveOptionItems(
    PlannedOutfitOption option,
    List<ClothingItem> wardrobe,
  ) {
    ClothingItem? byId(String? id) {
      if (id == null || id.isEmpty) return null;
      final found = wardrobe.where((item) => item.id == id);
      return found.isEmpty ? null : found.first;
    }

    return [
      byId(option.topId),
      byId(option.bottomId),
      byId(option.outerwearId),
      byId(option.footwearId),
      ...option.accessoryIds.map(byId),
    ].whereType<ClothingItem>().toList();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final initialDate = _eventDateTime ?? now.add(const Duration(days: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(
        now.year,
        now.month,
        now.day + AppConstants.maxForecastDaysAhead,
      ),
    );

    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_eventDateTime ?? now),
    );

    if (pickedTime == null) return;
    if (!mounted) return;

    setState(() {
      _eventDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _createPlan(
    PlanAheadProvider planner,
    WardrobeProvider wardrobe,
  ) async {
    if (_eventDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày giờ sự kiện.')),
      );
      return;
    }

    final location = _locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập địa điểm.')));
      return;
    }

    final success = await planner.createPlan(
      eventDateTime: _eventDateTime!,
      location: location,
      activityType: _activityType,
      customActivity: _customActivityController.text.trim().isEmpty
          ? null
          : _customActivityController.text.trim(),
      dressCode: _dressCodeController.text.trim().isEmpty
          ? null
          : _dressCodeController.text.trim(),
      wardrobeProvider: wardrobe,
    );

    if (!mounted) return;

    _showPendingMessages(planner);

    if (success) {
      setState(() {
        _customActivityController.clear();
        _dressCodeController.clear();
      });
    }
  }

  Future<void> _confirmDeletePlan(
    PlanAheadProvider planner,
    String planId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá kế hoạch?'),
        content: const Text('Bạn có chắc muốn xoá kế hoạch outfit này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await planner.deletePlan(planId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Đã xoá kế hoạch.' : 'Xoá thất bại, thử lại.'),
      ),
    );
  }

  void _showPendingMessages(PlanAheadProvider provider) {
    final messages = provider.consumeNotifications();
    if (messages.isEmpty || !mounted) return;

    for (final msg in messages) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  String _formatDateTime(DateTime value) {
    final dd = value.day.toString().padLeft(2, '0');
    final mm = value.month.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mn = value.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${value.year} $hh:$mn';
  }

  String _checkpointDisplay(String checkpoint) {
    switch (checkpoint) {
      case 't_minus_3':
        return 'T-3';
      case 't_minus_1':
        return 'T-1';
      case 'day_morning':
        return 'Sáng ngày đi';
      default:
        return checkpoint;
    }
  }
}
