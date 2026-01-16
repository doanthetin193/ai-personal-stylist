import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../models/outfit.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/outfit_card.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/common_widgets.dart';

class OutfitSuggestScreen extends StatefulWidget {
  const OutfitSuggestScreen({super.key});

  @override
  State<OutfitSuggestScreen> createState() => _OutfitSuggestScreenState();
}

class _OutfitSuggestScreenState extends State<OutfitSuggestScreen> {
  String? _selectedOccasion;
  String? _customOccasion;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFCE7F3), // Pink 100
              AppTheme.backgroundColor,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Premium Header
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gợi ý Outfit',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AI phân tích và gợi ý cho bạn',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Weather info
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

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Occasion selection - trong card đẹp
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: AppTheme.accentColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Bạn đi đâu hôm nay?',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            // Các dịp có sẵn
                            ...Occasions.list.map((occasion) {
                              final isSelected =
                                  _selectedOccasion == occasion['id'] &&
                                  _customOccasion == null;
                              return OccasionChip(
                                id: occasion['id']!,
                                name: occasion['name']!,
                                icon: occasion['icon']!,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    if (_selectedOccasion == occasion['id']) {
                                      _selectedOccasion = null; // Toggle off
                                    } else {
                                      _selectedOccasion = occasion['id'];
                                    }
                                    _customOccasion = null;
                                  });
                                },
                              );
                            }),
                            // Nút tự nhập
                            OccasionChip(
                              id: 'custom',
                              name: 'Tự nhập',
                              icon: '✏️',
                              isSelected: _customOccasion != null,
                              onTap: () => _showCustomOccasionDialog(),
                            ),
                          ],
                        ),
                        // Hiển thị dịp tự nhập nếu có
                        if (_customOccasion != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryColor),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.edit_note,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _customOccasion!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _customOccasion = null;
                                    });
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Generate button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          (_selectedOccasion != null ||
                                  _customOccasion != null) &&
                              !_isGenerating
                          ? _generateOutfit
                          : null,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(
                        _isGenerating
                            ? 'Đang tạo outfit...'
                            : 'Gợi ý outfit cho tôi',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Outfit result
              Consumer<WardrobeProvider>(
                builder: (context, wardrobe, _) {
                  if (wardrobe.isSuggestingOutfit) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: OutfitShimmer(),
                      ),
                    );
                  }

                  if (wardrobe.currentOutfit == null) {
                    return SliverToBoxAdapter(child: _buildEmptyState());
                  }

                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outfit được gợi ý',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutfitCard(
                            outfit: wardrobe.currentOutfit!,
                            onWear: () =>
                                _markOutfitAsWorn(wardrobe.currentOutfit!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.checkroom,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chọn dịp để bắt đầu',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI sẽ phân tích tủ đồ và thời tiết\nđể gợi ý outfit phù hợp nhất',
            style: TextStyle(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _generateOutfit() async {
    setState(() => _isGenerating = true);

    try {
      final wardrobeProvider = context.read<WardrobeProvider>();

      if (wardrobeProvider.allItems.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tủ đồ trống! Hãy thêm quần áo trước.'),
            ),
          );
        }
        return;
      }

      // Sử dụng custom occasion nếu có, ngược lại dùng occasion từ danh sách
      final occasionName =
          _customOccasion ?? Occasions.getName(_selectedOccasion!);
      await wardrobeProvider.suggestOutfit(occasionName);

      if (wardrobeProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(wardrobeProvider.errorMessage!)));
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showCustomOccasionDialog() {
    final dialogController = TextEditingController(text: _customOccasion ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Nhập dịp của bạn'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mô tả ngắn gọn dịp bạn muốn mặc đồ:',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: dialogController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'VD: Đi phỏng vấn, gặp đối tác, picnic...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.event),
              ),
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (value) {
                final text = value.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  setState(() {
                    _customOccasion = text;
                    _selectedOccasion = null;
                  });
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = dialogController.text.trim();
              Navigator.pop(dialogContext);
              if (text.isNotEmpty) {
                setState(() {
                  _customOccasion = text;
                  _selectedOccasion = null;
                });
              }
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _markOutfitAsWorn(Outfit outfit) {
    final wardrobeProvider = context.read<WardrobeProvider>();

    // Mark all items as worn
    for (final item in outfit.allItems) {
      wardrobeProvider.markAsWorn(item);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu outfit!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
