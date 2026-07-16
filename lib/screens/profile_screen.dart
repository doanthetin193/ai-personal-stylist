import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../models/clothing_item.dart';
import '../utils/theme.dart';
import 'wardrobe_cleanup_screen.dart';
import 'login_screen.dart';
import 'lookbook_screen.dart';

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
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
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
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (user?.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user!.email!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

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
                            value: wardrobeProvider.itemsByType.length
                                .toString(),
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
                      onTap: () =>
                          _showEditProfileDialog(context, authProvider),
                    ),
                    _buildMenuItem(
                      icon: Icons.bar_chart_rounded,
                      title: 'Thống kê tủ đồ',
                      subtitle: 'Xem chi tiết tủ đồ của bạn',
                      onTap: () =>
                          _showWardrobeStats(context, wardrobeProvider),
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite,
                      title: 'Lookbook (Set đồ đã lưu)',
                      subtitle: 'Những bộ đồ bạn yêu thích nhất',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LookbookScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.cleaning_services_outlined,
                      title: 'Dọn tủ đồ',
                      subtitle: 'AI gợi ý đồ nên bỏ',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WardrobeCleanupScreen(),
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.wc,
                      title: 'Giới tính hồ sơ',
                      subtitle: _getGenderSubtitle(wardrobeProvider),
                      onTap: () => _showGenderPreferenceDialog(
                        context,
                        wardrobeProvider,
                      ),
                    ),
                    _buildMenuItem(
                      icon: Icons.accessibility_new_rounded,
                      title: 'Hình thể & Phong thủy',
                      subtitle: _getPersonalProfileSubtitle(wardrobeProvider),
                      onTap: () => _showPersonalProfileDialog(context, wardrobeProvider),
                    ),
                    _buildMenuItem(
                      icon: Icons.style_outlined,
                      title: 'Sở thích phong cách',
                      subtitle: wardrobeProvider.stylePreference.displayName,
                      onTap: () =>
                          _showStylePreferenceDialog(context, wardrobeProvider),
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
                      icon: Icons.info_outline,
                      title: 'Về ứng dụng',
                      subtitle: 'Phiên bản 1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),

                    const SizedBox(height: 24),

                    // Logout button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(
                          Icons.logout,
                          color: AppTheme.errorColor,
                        ),
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

  String _getGenderSubtitle(WardrobeProvider wardrobeProvider) {
    final gender = wardrobeProvider.genderPreference;
    final styleProfile = wardrobeProvider.outfitStyleProfile;

    if (gender == null && styleProfile == null) {
      return 'Chưa thiết lập';
    }

    final genderLabel = gender?.displayName ?? 'Chưa chọn';
    final styleLabel = styleProfile?.displayName ?? 'Mặc định';
    return '$genderLabel • $styleLabel';
  }

  String _getPersonalProfileSubtitle(WardrobeProvider wp) {
    if (!wp.hasPersonalProfile) return 'Chưa thiết lập';
    return '${wp.fengShuiProfile?.displayString ?? ''} • BMI ${wp.bodyProfile?.bmi.toStringAsFixed(1) ?? ''}';
  }

  Widget _buildStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 24),
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
            color: Colors.white.withValues(alpha: 0.8),
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
      color: Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.checkroom, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'AI Personal Stylist',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            const Text(
              '© 2025 AI Personal Stylist',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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
    final authProvider = context.read<AuthProvider>();
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authProvider.signOut();
              // Force navigate to login screen và xóa hết navigation stack
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
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

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final nameController = TextEditingController(
      text: authProvider.user?.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Chỉnh sửa hồ sơ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: authProvider.user?.photoURL != null
                      ? NetworkImage(authProvider.user!.photoURL!)
                      : null,
                  child: authProvider.user?.photoURL == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tên hiển thị',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authProvider.user?.email ?? 'Chưa có email',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              final navigator = Navigator.of(context);
              if (newName.isNotEmpty) {
                await authProvider.updateDisplayName(newName);
              }
              navigator.pop();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showWardrobeStats(
    BuildContext context,
    WardrobeProvider wardrobeProvider,
  ) {
    final items = wardrobeProvider.allItems;
    final itemsByType = wardrobeProvider.itemsByType;

    // Calculate stats
    final totalItems = items.length;
    final favoriteCount = items.where((i) => i.isFavorite).length;
    final mostWornItem = items.isNotEmpty
        ? items.reduce((a, b) => a.wearCount > b.wearCount ? a : b)
        : null;
    final leastWornItems = items.where((i) => i.wearCount == 0).length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Thống kê tủ đồ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Overview stats
              Row(
                children: [
                  _buildStatCard(
                    icon: Icons.checkroom,
                    value: totalItems.toString(),
                    label: 'Tổng số đồ',
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.favorite,
                    value: favoriteCount.toString(),
                    label: 'Yêu thích',
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    icon: Icons.visibility_off,
                    value: leastWornItems.toString(),
                    label: 'Chưa mặc',
                    color: AppTheme.warningColor,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // By Color
              const Text(
                'Phân bổ màu sắc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),
              if (totalItems > 0)
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _buildColorChartSections(items),
                    ),
                  ),
                )
              else
                const Text('Chưa có đủ đồ để vẽ biểu đồ.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              // By type
              const Text(
                'Theo loại',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ...itemsByType.entries.map((entry) {
                final percentage = (entry.value.length / totalItems * 100)
                    .toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.key.displayName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: entry.value.length / totalItems,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation(
                              AppTheme.primaryColor,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.value.length} ($percentage%)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              if (mostWornItem != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Đồ mặc nhiều nhất',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        color: AppTheme.warningColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${mostWornItem.type.displayName} - ${mostWornItem.color}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Đã mặc ${mostWornItem.wearCount} lần',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showStylePreferenceDialog(
    BuildContext context,
    WardrobeProvider wardrobeProvider,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sở thích phong cách',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'AI sẽ ưu tiên gợi ý outfit theo sở thích của bạn',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            RadioGroup<StylePreference>(
              groupValue: wardrobeProvider.stylePreference,
              onChanged: (StylePreference? value) {
                if (value != null) {
                  wardrobeProvider.setStylePreference(value);
                  Navigator.pop(context);
                }
              },
              child: Column(
                children: StylePreference.values
                    .map(
                      (style) => RadioListTile<StylePreference>(
                        value: style,
                        title: Text(style.displayName),
                        subtitle: Text(
                          _getStyleDescription(style),
                          style: const TextStyle(fontSize: 12),
                        ),
                        activeColor: AppTheme.primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _getStyleDescription(StylePreference style) {
    switch (style) {
      case StylePreference.loose:
        return 'Thoải mái, oversized, không bó sát';
      case StylePreference.regular:
        return 'Cân bằng, phù hợp mọi dáng người';
      case StylePreference.fitted:
        return 'Ôm sát, tôn dáng, sleek';
    }
  }

  void _showGenderPreferenceDialog(
    BuildContext outerContext,
    WardrobeProvider wardrobeProvider,
  ) {
    GenderPreference selectedGender =
        wardrobeProvider.genderPreference ?? GenderPreference.male;
    OutfitStyleProfile selectedStyleProfile =
        wardrobeProvider.outfitStyleProfile ??
        OutfitStyleProfile.defaultForGender(selectedGender);

    showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (modalContext, setState) {
          final maxHeight = MediaQuery.of(sheetContext).size.height * 0.88;

          return SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Giới tính hồ sơ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Thiết lập này giúp AI gợi ý outfit hợp lý và đúng vibe bạn mong muốn.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            RadioListTile<GenderPreference>(
                              value: GenderPreference.male,
                              groupValue: selectedGender,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => selectedGender = value);
                                }
                              },
                              title: const Text('Nam'),
                              activeColor: AppTheme.primaryColor,
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile<GenderPreference>(
                              value: GenderPreference.female,
                              groupValue: selectedGender,
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => selectedGender = value);
                                }
                              },
                              title: const Text('Nữ'),
                              activeColor: AppTheme.primaryColor,
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
                                    setState(
                                      () => selectedStyleProfile = value,
                                    );
                                  }
                                },
                                title: Text(profile.displayName),
                                subtitle: Text(profile.description),
                                activeColor: AppTheme.primaryColor,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final saved = await wardrobeProvider
                              .saveIdentityPreferences(
                                gender: selectedGender,
                                styleProfile: selectedStyleProfile,
                              );

                          if (!outerContext.mounted) return;

                          if (saved) {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(outerContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Đã cập nhật hồ sơ giới tính và phong cách',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(outerContext).showSnackBar(
                              const SnackBar(
                                content: Text('Lưu thất bại, vui lòng thử lại'),
                              ),
                            );
                          }
                        },
                        child: const Text('Lưu thay đổi'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPersonalProfileDialog(
      BuildContext context, WardrobeProvider provider) {
    final yearController = TextEditingController(
        text: provider.birthYear?.toString() ?? '');
    final heightController = TextEditingController(
        text: provider.heightCm?.toString() ?? '');
    final weightController = TextEditingController(
        text: provider.weightKg?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Hình thể & Phong thủy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nhập thông tin để AI gợi ý trang phục chuẩn xác nhất!',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Năm sinh (VD: 2002)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chiều cao (cm)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cân nặng (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final y = int.tryParse(yearController.text);
                final h = int.tryParse(heightController.text);
                final w = int.tryParse(weightController.text);

                if (y != null && h != null && w != null) {
                  await provider.updatePersonalProfile(y, h, w);
                  if (context.mounted) Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập đúng định dạng số!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Lưu & Cập nhật'),
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _buildColorChartSections(List<ClothingItem> items) {
    if (items.isEmpty) return [];

    final Map<String, int> colorCount = {};
    for (var item in items) {
      final color = item.color.toLowerCase();
      colorCount[color] = (colorCount[color] ?? 0) + 1;
    }

    final total = items.length;
    int colorIndex = 0;
    
    Color getColor(String colorName, int index) {
      final name = colorName.toLowerCase();
      if (name.contains('đen') || name.contains('black')) return Colors.black87;
      if (name.contains('trắng') || name.contains('white')) return Colors.grey.shade400;
      if (name.contains('đỏ') || name.contains('red')) return Colors.red;
      if (name.contains('xanh dương') || name.contains('blue')) return Colors.blue;
      if (name.contains('xanh lá') || name.contains('green')) return Colors.green;
      if (name.contains('vàng') || name.contains('yellow')) return Colors.amber;
      if (name.contains('hồng') || name.contains('pink')) return Colors.pinkAccent;
      if (name.contains('tím') || name.contains('purple')) return Colors.purple;
      if (name.contains('xám') || name.contains('grey') || name.contains('gray')) return Colors.grey;
      if (name.contains('nâu') || name.contains('brown')) return Colors.brown;
      if (name.contains('be') || name.contains('beige')) return const Color(0xFFD2B48C);
      if (name.contains('cam') || name.contains('orange')) return Colors.orange;
      
      final colors = [Colors.teal, Colors.cyan, Colors.indigo, Colors.lime, Colors.deepOrange];
      return colors[index % colors.length];
    }

    return colorCount.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = getColor(entry.key, colorIndex++);
      
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
        ),
        badgeWidget: percentage >= 5 ? _Badge(entry.key, color) : null,
        badgePositionPercentageOffset: 1.25,
      );
    }).toList();
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bgColor;

  const _Badge(this.text, this.bgColor);

  @override
  Widget build(BuildContext context) {
    final textColor = bgColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2),
        ],
      ),
      child: Text(
        text.length > 10 ? '${text.substring(0, 10)}...' : text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
