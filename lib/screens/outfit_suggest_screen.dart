import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wardrobe_provider.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../widgets/outfit_card.dart';
import '../widgets/clothing_card.dart';
import '../widgets/loading_widgets.dart';
import '../widgets/common_widgets.dart';

class OutfitSuggestScreen extends StatefulWidget {
  const OutfitSuggestScreen({super.key});

  @override
  State<OutfitSuggestScreen> createState() => _OutfitSuggestScreenState();
}

class _OutfitSuggestScreenState extends State<OutfitSuggestScreen> {
  String? _selectedOccasion;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gợi ý Outfit',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chọn dịp và để AI gợi ý cho bạn',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
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
                    return WeatherWidget(
                      weather: wardrobe.weather!,
                      compact: false,
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Occasion selection
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bạn đi đâu?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: Occasions.list.map((occasion) {
                        final isSelected = _selectedOccasion == occasion['id'];
                        return OccasionChip(
                          id: occasion['id']!,
                          name: occasion['name']!,
                          icon: occasion['icon']!,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() => _selectedOccasion = occasion['id']);
                          },
                        );
                      }).toList(),
                    ),
                  ],
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
                    onPressed: _selectedOccasion != null && !_isGenerating
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
                      _isGenerating ? 'Đang tạo outfit...' : 'Gợi ý outfit cho tôi',
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
                  return SliverToBoxAdapter(
                    child: _buildEmptyState(),
                  );
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
                          onWear: () => _markOutfitAsWorn(wardrobe.currentOutfit!),
                          onSave: () {
                            // Save outfit logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã lưu outfit!')),
                            );
                          },
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
              color: AppTheme.primaryColor.withOpacity(0.1),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI sẽ phân tích tủ đồ và thời tiết\nđể gợi ý outfit phù hợp nhất',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _generateOutfit() async {
    if (_selectedOccasion == null) return;

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

      final occasionName = Occasions.getName(_selectedOccasion!);
      await wardrobeProvider.suggestOutfit(occasionName);

      if (wardrobeProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(wardrobeProvider.errorMessage!)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
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
