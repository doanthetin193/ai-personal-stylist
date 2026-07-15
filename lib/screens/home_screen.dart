import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../providers/plan_ahead_provider.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/clothing_card.dart';
import 'wardrobe_screen.dart';
import 'outfit_suggest_screen.dart';
import 'color_harmony_screen.dart';
import 'wardrobe_cleanup_screen.dart';
import 'add_item_screen.dart';
import 'plan_ahead_screen.dart';
import 'profile_screen.dart';
import 'tinder_outfit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _HomeTab(onViewAllTap: () => _navigateToTab(1)),
      const WardrobeScreen(),
      const OutfitSuggestScreen(),
      const ProfileScreen(),
    ];
    // Load data khi vào home
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final wardrobeProvider = context.read<WardrobeProvider>();
      await wardrobeProvider.loadGenderPreference();
      wardrobeProvider.loadItems();
      wardrobeProvider.loadWeather();

      if (!mounted || wardrobeProvider.hasIdentityPreferences) return;
      await _showInitialIdentityDialog(wardrobeProvider);
    });
  }

  Future<void> _showInitialIdentityDialog(
    WardrobeProvider wardrobeProvider,
  ) async {
    final rootContext = context;
    GenderPreference selectedGender =
        wardrobeProvider.genderPreference ?? GenderPreference.male;
    OutfitStyleProfile selectedStyleProfile =
        wardrobeProvider.outfitStyleProfile ??
        OutfitStyleProfile.defaultForGender(selectedGender);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Chọn giới tính hồ sơ'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Để gợi ý outfit hợp lý hơn, bạn vui lòng chọn giới tính và phong cách hồ sơ trước khi sử dụng.',
                    ),
                    const SizedBox(height: 16),
                    RadioListTile<GenderPreference>(
                      value: GenderPreference.male,
                      groupValue: selectedGender,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedGender = value;
                            if (selectedStyleProfile ==
                                    OutfitStyleProfile.defaultForGender(
                                      value == GenderPreference.male
                                          ? GenderPreference.female
                                          : GenderPreference.male,
                                    ) ||
                                selectedStyleProfile ==
                                    OutfitStyleProfile.defaultForGender(null)) {
                              selectedStyleProfile =
                                  OutfitStyleProfile.defaultForGender(value);
                            }
                          });
                        }
                      },
                      title: const Text('Nam'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<GenderPreference>(
                      value: GenderPreference.female,
                      groupValue: selectedGender,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedGender = value;
                            if (selectedStyleProfile ==
                                    OutfitStyleProfile.defaultForGender(
                                      value == GenderPreference.male
                                          ? GenderPreference.female
                                          : GenderPreference.male,
                                    ) ||
                                selectedStyleProfile ==
                                    OutfitStyleProfile.defaultForGender(null)) {
                              selectedStyleProfile =
                                  OutfitStyleProfile.defaultForGender(value);
                            }
                          });
                        }
                      },
                      title: const Text('Nữ'),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Phong cách hồ sơ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...OutfitStyleProfile.values.map(
                      (profile) => RadioListTile<OutfitStyleProfile>(
                        value: profile,
                        groupValue: selectedStyleProfile,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedStyleProfile = value);
                          }
                        },
                        title: Text(profile.displayName),
                        subtitle: Text(profile.description),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  final success = await wardrobeProvider
                      .saveIdentityPreferences(
                        gender: selectedGender,
                        styleProfile: selectedStyleProfile,
                      );

                  if (!mounted) return;

                  if (success) {
                    Navigator.of(dialogContext).pop();
                  } else {
                    ScaffoldMessenger.of(rootContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Không lưu được giới tính. Vui lòng thử lại.',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to specific tab - public method for child widgets
  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppTheme.primaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.checkroom_rounded, 'Tủ đồ'),
                _buildAddButton(),
                _buildNavItem(2, Icons.auto_awesome, 'Phối đồ'),
                _buildNavItem(3, Icons.person_rounded, 'Tôi'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _navigateToAddItem(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _navigateToAddItem() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddItemScreen()),
    );
  }
}

/// Tab Home chính
class _HomeTab extends StatelessWidget {
  final VoidCallback? onViewAllTap;

  const _HomeTab({this.onViewAllTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE0E7FF), // Indigo 100
            Color(0xFFF3E8FF), // Purple 100
            AppTheme.backgroundColor,
          ],
          stops: [0.0, 0.2, 0.4],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Premium Header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar với gradient border
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: auth.photoUrl != null
                              ? NetworkImage(auth.photoUrl!)
                              : null,
                          child: auth.photoUrl == null
                              ? const Icon(
                                  Icons.person,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Greeting text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                getGreeting(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('👋', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) => Text(
                              auth.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification icon
                    Consumer<PlanAheadProvider>(
                      builder: (context, planProvider, _) {
                        final hasNotifications = planProvider.notifications.isNotEmpty;
                        return GestureDetector(
                          onTap: () => _showNotificationsDialog(context, planProvider),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.notifications_outlined,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                if (hasNotifications)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Weather Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<WardrobeProvider>(
                  builder: (context, wardrobe, _) {
                    if (wardrobe.weather == null) {
                      return const SizedBox.shrink();
                    }
                    return GestureDetector(
                      onTap: () => _showChangeLocationDialog(context, wardrobe),
                      child: WeatherWidget(weather: wardrobe.weather!),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Fashion Quote (Sleek Compact Version)
            const SliverToBoxAdapter(
              child: _FashionQuoteWidget(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hành động nhanh',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.add_a_photo,
                            title: 'Thêm đồ mới',
                            color: AppTheme.primaryColor,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddItemScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.auto_awesome,
                            title: 'Gợi ý outfit',
                            color: AppTheme.accentColor,
                            onTap: () {
                              // Navigate to Outfit tab (index 2)
                              final homeState = context
                                  .findAncestorStateOfType<_HomeScreenState>();
                              homeState?._navigateToTab(2);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.palette,
                            title: 'Chấm màu',
                            color: AppTheme.secondaryColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ColorHarmonyScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.cleaning_services,
                            title: 'Dọn tủ đồ',
                            color: AppTheme.warningColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WardrobeCleanupScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _QuickActionCard(
                      icon: Icons.event_available,
                      title: 'Lên kế hoạch outfit (Plan Ahead)',
                      color: const Color(0xFF0284C7),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlanAheadScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _QuickActionCard(
                      icon: Icons.local_fire_department_rounded,
                      title: 'Quẹt Outfit (Mix ngẫu nhiên) 🔥',
                      color: Colors.pink.shade500,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TinderOutfitScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Recent Items
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thêm gần đây',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: onViewAllTap,
                      child: const Text('Xem tất cả'),
                    ),
                  ],
                ),
              ),
            ),

            // Recent items list
            Consumer<WardrobeProvider>(
              builder: (context, wardrobe, _) {
                if (wardrobe.isLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (wardrobe.allItems.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: EmptyState(
                        icon: Icons.checkroom,
                        title: 'Tủ đồ trống',
                        subtitle: 'Hãy thêm quần áo đầu tiên của bạn!',
                        action: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddItemScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm ngay'),
                        ),
                      ),
                    ),
                  );
                }

                final recentItems = wardrobe.allItems.take(4).toList();
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 150,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: recentItems.length,
                      itemBuilder: (context, index) {
                        final item = recentItems[index];
                        return Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ClothingImage(
                                    item: item,
                                    fit: BoxFit.cover,
                                    errorWidget: Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.image),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.type.displayName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  void _showChangeLocationDialog(
    BuildContext context,
    WardrobeProvider wardrobe,
  ) {
    final cities = [
      {'name': 'Quy Nhon', 'display': 'Quy Nhơn, Bình Định'},
      {'name': 'Ho Chi Minh City', 'display': 'TP. Hồ Chí Minh'},
      {'name': 'Hanoi', 'display': 'Hà Nội'},
      {'name': 'Da Nang', 'display': 'Đà Nẵng'},
      {'name': 'Nha Trang', 'display': 'Nha Trang'},
      {'name': 'Can Tho', 'display': 'Cần Thơ'},
      {'name': 'Hai Phong', 'display': 'Hải Phòng'},
      {'name': 'Hue', 'display': 'Huế'},
      {'name': 'Vung Tau', 'display': 'Vũng Tàu'},
      {'name': 'Bien Hoa', 'display': 'Biên Hòa'},
      {'name': 'Pleiku', 'display': 'Pleiku, Gia Lai'},
      {'name': 'Buon Ma Thuot', 'display': 'Buôn Ma Thuột'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Chọn thành phố',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Hiện tại: ${wardrobe.weather?.cityName ?? "Không xác định"}',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  final currentCity = wardrobe.weather?.cityName;
                  final isSelected =
                      currentCity != null &&
                      currentCity.toLowerCase() == city['name']!.toLowerCase();

                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.location_city,
                      color: isSelected
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                    title: Text(
                      city['display']!,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      wardrobe.changeWeatherLocation(city['name']!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đang cập nhật thời tiết ${city['display']}...',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context, PlanAheadProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final notes = provider.notifications;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notifications, color: AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Thông báo',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (notes.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        provider.clearNotifications();
                        Navigator.pop(context);
                      },
                      child: const Text('Đánh dấu đã đọc'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (notes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'Bạn không có thông báo mới nào!',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: notes.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.event_available, color: AppTheme.accentColor),
                        title: Text(notes[index]),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color.withValues(alpha: 0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FashionQuoteWidget extends StatefulWidget {
  const _FashionQuoteWidget({super.key});

  @override
  State<_FashionQuoteWidget> createState() => _FashionQuoteWidgetState();
}

class _FashionQuoteWidgetState extends State<_FashionQuoteWidget> {
  final List<String> _quotes = [
    '"Phong cách nói lên bạn là ai mà không cần mở lời."\n- Rachel Zoe',
    '"Hãy quyết định bạn là ai qua cách ăn mặc."\n- Gianni Versace',
    '"Sự thanh lịch là vẻ đẹp không bao giờ tàn phai."\n- Audrey Hepburn',
    '"Thời trang phai tàn, nhưng phong cách là mãi mãi."\n- Y.S.Laurent',
    '"Mặc đẹp là một cách thể hiện sự tôn trọng."\n- Tom Ford',
    '"Thời trang là một bản nhạc tuyệt vời."\n- Michael Kors',
    '"Đừng mặc để tỏa sáng, hãy mặc để được nhớ đến."\n- Giorgio Armani',
    '"Người mặc mang lại sự sống cho quần áo."\n- Marc Jacobs',
    '"Phong cách là nói lên những điều phức tạp một cách đơn giản."\n- Jean Cocteau',
    '"Trang phục đẹp nhất chính là sự tự tin của bạn."\n- Blake Lively'
  ];

  late int _currentIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _quotes.shuffle();
    _currentIndex = 0;
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _quotes.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuote = _quotes[_currentIndex];
    final quoteParts = currentQuote.split('\n- ');
    final quoteText = quoteParts[0];
    final authorText = quoteParts.length > 1 ? quoteParts[1] : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56, // Fixed height for 2 lines + author
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    key: ValueKey<int>(_currentIndex),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quoteText,
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (authorText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            authorText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

