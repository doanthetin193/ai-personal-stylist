import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../models/clothing_item.dart';
import '../utils/theme.dart';
import '../widgets/clothing_card.dart';

class WardrobeCleanupScreen extends StatefulWidget {
  const WardrobeCleanupScreen({super.key});

  @override
  State<WardrobeCleanupScreen> createState() => _WardrobeCleanupScreenState();
}

class _WardrobeCleanupScreenState extends State<WardrobeCleanupScreen> {
  bool _isAnalyzing = false;
  Map<String, dynamic>? _suggestions;
  final Set<String> _selectedForRemoval = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Dọn tủ đồ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_selectedForRemoval.isNotEmpty)
            TextButton.icon(
              onPressed: _confirmRemoval,
              icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              label: Text(
                'Xóa (${_selectedForRemoval.length})',
                style: const TextStyle(color: AppTheme.errorColor),
              ),
            ),
          IconButton(
            onPressed: () => _showDeleteAllDialog(context),
            icon: const Icon(Icons.delete_forever, color: AppTheme.errorColor),
            tooltip: 'Xóa tất cả',
          ),
        ],
      ),
      body: Consumer<WardrobeProvider>(
        builder: (context, wardrobe, _) {
          if (wardrobe.allItems.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                _buildInfoCard(),
                
                const SizedBox(height: 20),

                // Analyze button
                if (_suggestions == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : () => _analyzeWardrobe(wardrobe),
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_isAnalyzing ? 'Đang phân tích...' : 'AI Phân tích tủ đồ'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                // Results
                if (_suggestions != null) ...[
                  _buildSuggestionsSection(wardrobe),
                ],

                const SizedBox(height: 24),

                // Manual cleanup section
                _buildManualCleanupSection(wardrobe),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checkroom_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tủ đồ trống',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thêm quần áo vào tủ đồ trước',
            style: TextStyle(color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.warningColor.withValues(alpha: 0.1),
            AppTheme.warningColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.cleaning_services,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dọn dẹp thông minh',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AI sẽ phân tích và gợi ý những món đồ nên bỏ hoặc donate',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(WardrobeProvider wardrobe) {
    final duplicates = _suggestions!['duplicates'] as List? ?? [];
    final mismatched = _suggestions!['mismatched'] as List? ?? [];
    final tips = _suggestions!['suggestions'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Duplicates
        if (duplicates.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('🔄 Đồ trùng lặp', duplicates.length),
          const SizedBox(height: 12),
          ...duplicates.map((dup) {
            final ids = (dup['ids'] as List?)?.cast<String>() ?? [];
            final reason = dup['reason'] as String? ?? '';
            final items = ids
                .map((id) => wardrobe.allItems.where((i) => i.id == id).firstOrNull)
                .where((i) => i != null)
                .cast<ClothingItem>()
                .toList();

            if (items.isEmpty) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: items.map((item) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildSelectableItem(item),
                      ),
                    )).toList(),
                  ),
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      reason,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],

        // Mismatched items
        if (mismatched.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('⚠️ Đồ không phù hợp', mismatched.length),
          const SizedBox(height: 12),
          ...mismatched.map((mis) {
            final id = mis['id'] as String? ?? '';
            final reason = mis['reason'] as String? ?? '';
            final item = wardrobe.allItems.where((i) => i.id == id).firstOrNull;

            if (item == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: _buildSelectableItem(item),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.type.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reason,
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
            );
          }),
        ],

        // General tips
        if (tips.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionTitle('💡 Gợi ý', tips.length),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip.toString(),
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],

        // Re-analyze button
        const SizedBox(height: 20),
        Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _suggestions = null;
                _selectedForRemoval.clear();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Phân tích lại'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableItem(ClothingItem item) {
    final isSelected = _selectedForRemoval.contains(item.id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedForRemoval.remove(item.id);
          } else {
            _selectedForRemoval.add(item.id);
          }
        });
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClothingImage(
                item: item,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppTheme.errorColor : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
          ),
          if (isSelected)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildManualCleanupSection(WardrobeProvider wardrobe) {
    // Group items by type for manual review
    final itemsByType = wardrobe.itemsByType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dọn dẹp thủ công',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Chọn những món đồ bạn muốn bỏ',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),

        // Items grid grouped by type
        ...itemsByType.entries.map((entry) {
          final type = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '${type.displayName} (${items.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildSelectableItem(items[index]);
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  Future<void> _analyzeWardrobe(WardrobeProvider wardrobe) async {
    setState(() => _isAnalyzing = true);

    try {
      final suggestions = await wardrobe.getCleanupSuggestions();
      
      if (suggestions != null) {
        setState(() => _suggestions = suggestions);
      } else {
        // Fallback suggestions
        setState(() {
          _suggestions = {
            'duplicates': [],
            'mismatched': [],
            'suggestions': [
              'Tủ đồ của bạn khá gọn gàng!',
              'Hãy xem xét donate những món đồ không mặc trong 6 tháng qua.',
              'Giữ tủ đồ với những item đa năng, dễ phối.',
            ],
          };
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _confirmRemoval() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa ${_selectedForRemoval.length} món đồ khỏi tủ?\n\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeSelectedItems();
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

  Future<void> _removeSelectedItems() async {
    final wardrobe = context.read<WardrobeProvider>();
    
    for (final id in _selectedForRemoval) {
      await wardrobe.deleteItem(id);
    }

    setState(() {
      _selectedForRemoval.clear();
      _suggestions = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa các món đồ đã chọn'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _showDeleteAllDialog(BuildContext context) {
    final wardrobe = context.read<WardrobeProvider>();
    final totalItems = wardrobe.allItems.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            const Text('Xóa tất cả?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn có chắc muốn xóa TẤT CẢ $totalItems món đồ trong tủ?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.errorColor, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hành động này KHÔNG THỂ hoàn tác!',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
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
              Navigator.pop(context);
              await _deleteAllItems();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllItems() async {
    final wardrobe = context.read<WardrobeProvider>();
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Đang xóa tất cả...'),
          ],
        ),
      ),
    );

    final success = await wardrobe.deleteAllItems();
    
    // Close loading
    if (mounted) Navigator.pop(context);

    setState(() {
      _selectedForRemoval.clear();
      _suggestions = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đã xóa tất cả!' : 'Có lỗi xảy ra'),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }
}
