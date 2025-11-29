import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/clothing_card.dart';
import 'wardrobe_screen.dart';
import 'outfit_suggest_screen.dart';
import 'add_item_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeTab(),
    const WardrobeScreen(),
    const OutfitSuggestScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load data khi vào home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final wardrobeProvider = context.read<WardrobeProvider>();
      wardrobeProvider.loadItems();
      wardrobeProvider.loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                _buildNavItem(0, Icons.home_rounded, 'Trang chủ'),
                _buildNavItem(1, Icons.checkroom_rounded, 'Tủ đồ'),
                _buildAddButton(),
                _buildNavItem(2, Icons.auto_awesome, 'Phối đồ'),
                _buildNavItem(3, Icons.person_rounded, 'Tài khoản'),
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
              ? AppTheme.primaryColor.withOpacity(0.1) 
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
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
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
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getGreeting(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) => Text(
                                auth.displayName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) => CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          backgroundImage: auth.photoUrl != null
                              ? NetworkImage(auth.photoUrl!)
                              : null,
                          child: auth.photoUrl == null
                              ? const Icon(Icons.person, color: AppTheme.primaryColor)
                              : null,
                        ),
                      ),
                    ],
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
                  return WeatherWidget(weather: wardrobe.weather!);
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.add_a_photo,
                          title: 'Thêm đồ mới',
                          color: AppTheme.primaryColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddItemScreen()),
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
                            // Navigate to outfit suggest
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.palette,
                          title: 'Chấm màu',
                          color: AppTheme.secondaryColor,
                          onTap: () {
                            // Navigate to color harmony
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
                            // Navigate to cleanup
                          },
                        ),
                      ),
                    ],
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
                    onPressed: () {
                      // Navigate to wardrobe
                    },
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
                          MaterialPageRoute(builder: (_) => const AddItemScreen()),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
