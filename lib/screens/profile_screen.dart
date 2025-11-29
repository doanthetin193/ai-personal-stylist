import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../utils/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer2<AuthProvider, WardrobeProvider>(
        builder: (context, authProvider, wardrobeProvider, _) {
          final user = authProvider.user;

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppTheme.textSecondary,
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Name
                      Text(
                        user?.displayName ?? 'Người dùng',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (user?.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user!.email!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat(
                            label: 'Tổng đồ',
                            value: wardrobeProvider.allItems.length.toString(),
                            icon: Icons.checkroom,
                          ),
                          _buildDivider(),
                          _buildStat(
                            label: 'Loại đồ',
                            value: wardrobeProvider.itemsByType.length.toString(),
                            icon: Icons.style,
                          ),
                          _buildDivider(),
                          _buildStat(
                            label: 'Yêu thích',
                            value: wardrobeProvider.allItems
                                .where((i) => i.isFavorite)
                                .length
                                .toString(),
                            icon: Icons.favorite,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Menu items
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'Cài đặt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Thông tin cá nhân',
                      subtitle: 'Chỉnh sửa hồ sơ của bạn',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Thông báo',
                      subtitle: 'Quản lý cài đặt thông báo',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.palette_outlined,
                      title: 'Phong cách yêu thích',
                      subtitle: 'Thiết lập sở thích thời trang',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.cloud_outlined,
                      title: 'Đồng bộ dữ liệu',
                      subtitle: 'Sao lưu và khôi phục tủ đồ',
                      onTap: () => _showComingSoon(context),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Khác',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Trợ giúp & Hỗ trợ',
                      subtitle: 'Câu hỏi thường gặp',
                      onTap: () => _showComingSoon(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'Về ứng dụng',
                      subtitle: 'Phiên bản 1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.star_outline,
                      title: 'Đánh giá ứng dụng',
                      subtitle: 'Chia sẻ trải nghiệm của bạn',
                      onTap: () => _showComingSoon(context),
                    ),

                    const SizedBox(height: 24),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.errorColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang phát triển'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checkroom,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AI Personal Stylist',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phiên bản 1.0.0',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ứng dụng quản lý tủ đồ thông minh với AI, giúp bạn phối đồ hoàn hảo mỗi ngày.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '© 2024 AI Personal Stylist',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Đăng xuất?'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
