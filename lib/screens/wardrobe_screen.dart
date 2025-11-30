import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../models/clothing_item.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../widgets/clothing_card.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/common_widgets.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'Tất cả', 'icon': Icons.grid_view},
    {'id': 'top', 'name': 'Áo', 'icon': Icons.checkroom},
    {'id': 'bottom', 'name': 'Quần', 'icon': Icons.straighten},
    {'id': 'outerwear', 'name': 'Khoác', 'icon': Icons.dry_cleaning},
    {'id': 'dress', 'name': 'Váy', 'icon': Icons.dry},
    {'id': 'footwear', 'name': 'Giày', 'icon': Icons.ice_skating},
    {'id': 'bag', 'name': 'Túi', 'icon': Icons.shopping_bag},
    {'id': 'hat', 'name': 'Mũ', 'icon': Icons.face_retouching_natural},
    {'id': 'accessory', 'name': 'Phụ kiện', 'icon': Icons.watch},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header with gradient
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.15),
                    AppTheme.secondaryColor.withValues(alpha: 0.08),
                    AppTheme.accentColor.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Icon với gradient background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.checkroom_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title & subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tủ đồ của tôi',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Quản lý trang phục của bạn',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge số món đồ
                  Consumer<WardrobeProvider>(
                    builder: (context, wardrobe, _) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${wardrobe.allItems.length} món',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category Filter
            SizedBox(
              height: 44,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category['id'];
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = category['id']);
                        final wardrobeProvider = context.read<WardrobeProvider>();
                        if (category['id'] == 'all') {
                          wardrobeProvider.clearFilter();
                        } else {
                          wardrobeProvider.setFilterCategory(category['id']);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: isSelected 
                              ? AppTheme.primaryGradient 
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.transparent 
                                : Colors.grey.shade300,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              category['icon'],
                              size: 18,
                              color: isSelected 
                                  ? Colors.white 
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              category['name'],
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white 
                                    : AppTheme.textSecondary,
                                fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Grid
            Expanded(
              child: Consumer<WardrobeProvider>(
                builder: (context, wardrobe, _) {
                  if (wardrobe.isLoading) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: ClothingGridShimmer(),
                    );
                  }

                  if (wardrobe.items.isEmpty) {
                    return EmptyState(
                      icon: Icons.checkroom,
                      title: _selectedCategory == 'all'
                          ? 'Tủ đồ trống'
                          : 'Không có món đồ nào',
                      subtitle: _selectedCategory == 'all'
                          ? 'Hãy thêm quần áo để bắt đầu!'
                          : 'Thử chọn danh mục khác',
                      action: _selectedCategory == 'all'
                          ? ElevatedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddItemScreen(),
                                ),
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Thêm đồ mới'),
                            )
                          : null,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => wardrobe.loadItems(),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: wardrobe.items.length,
                      itemBuilder: (context, index) {
                        final item = wardrobe.items[index];
                        return ClothingCard(
                          item: item,
                          onTap: () => _navigateToDetail(item),
                          onLongPress: () => _showItemOptions(item),
                          onFavorite: () => wardrobe.toggleFavorite(item),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(ClothingItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(item: item),
      ),
    );
  }

  void _showItemOptions(ClothingItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Item preview
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: ClothingImage(
                      item: item,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        getColorNameVN(item.color),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Options
            _buildOptionTile(
              icon: Icons.visibility,
              title: 'Xem chi tiết',
              onTap: () {
                Navigator.pop(context);
                _navigateToDetail(item);
              },
            ),
            _buildOptionTile(
              icon: item.isFavorite ? Icons.favorite : Icons.favorite_border,
              title: item.isFavorite ? 'Bỏ yêu thích' : 'Yêu thích',
              onTap: () {
                context.read<WardrobeProvider>().toggleFavorite(item);
                Navigator.pop(context);
              },
            ),
            _buildOptionTile(
              icon: Icons.checkroom,
              title: 'Đánh dấu đã mặc',
              onTap: () {
                context.read<WardrobeProvider>().markAsWorn(item);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã cập nhật!')),
                );
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_outline,
              title: 'Xóa',
              color: AppTheme.errorColor,
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.textPrimary),
      title: Text(
        title,
        style: TextStyle(color: color ?? AppTheme.textPrimary),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _confirmDelete(ClothingItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa ${item.type.displayName} này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final wardrobeProvider = context.read<WardrobeProvider>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final success = await wardrobeProvider.deleteItem(item.id);
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Đã xóa thành công!' : 'Không thể xóa',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
