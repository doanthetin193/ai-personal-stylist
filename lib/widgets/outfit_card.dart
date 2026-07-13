import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../models/clothing_item.dart';
import '../utils/theme.dart';
import 'clothing_card.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onWear;
  final VoidCallback? onSave;

  const OutfitCard({super.key, required this.outfit, this.onWear, this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  outfit.occasion,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),

          const SizedBox(height: 16),

          // Items display
          _buildItemsGrid(),

          const SizedBox(height: 16),

          // Reason
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    outfit.reason,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Actions
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onWear,
                    child: const Text(
                      'Mặc hôm nay',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (onSave != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSave,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.pink),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.favorite_border, size: 16, color: Colors.pink),
                          SizedBox(width: 4),
                          Text(
                            'Lưu',
                            style: TextStyle(
                              color: Colors.pink,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid() {
    final items = outfit.allItems;

    if (items.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text('Không có item'),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (outfit.top != null) _buildItemWithLabel(outfit.top!, 'Áo'),
        if (outfit.bottom != null) _buildItemWithLabel(outfit.bottom!, 'Quần'),
        if (outfit.outerwear != null)
          _buildItemWithLabel(outfit.outerwear!, 'Khoác'),
        if (outfit.footwear != null)
          _buildItemWithLabel(outfit.footwear!, 'Giày'),
        ...outfit.accessories.map(
          (item) => _buildItemWithLabel(item, 'Phụ kiện'),
        ),
      ],
    );
  }

  Widget _buildItemWithLabel(ClothingItem item, String label) {
    return Column(
      children: [
        ClothingCardMini(item: item, size: 70),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
