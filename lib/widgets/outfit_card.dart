import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../models/clothing_item.dart';
import '../utils/theme.dart';
import 'clothing_card.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onTap;
  final VoidCallback? onWear;
  final bool showActions;

  const OutfitCard({
    super.key,
    required this.outfit,
    this.onTap,
    this.onWear,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                if (outfit.colorScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(outfit.colorScore!).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.palette,
                          size: 14,
                          color: _getScoreColor(outfit.colorScore!),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${outfit.colorScore}',
                          style: TextStyle(
                            color: _getScoreColor(outfit.colorScore!),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
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
            if (showActions) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onWear,
                  icon: const Icon(Icons.checkroom, size: 18),
                  label: const Text('Mặc hôm nay'),
                ),
              ),
            ],
          ],
        ),
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
        if (outfit.top != null)
          _buildItemWithLabel(outfit.top!, 'Áo'),
        if (outfit.bottom != null)
          _buildItemWithLabel(outfit.bottom!, 'Quần'),
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
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return AppTheme.accentColor;
    if (score >= 40) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}

/// Outfit preview đơn giản
class OutfitPreview extends StatelessWidget {
  final Outfit outfit;
  final VoidCallback? onTap;

  const OutfitPreview({
    super.key,
    required this.outfit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Items preview (stacked)
            SizedBox(
              width: 100,
              height: 60,
              child: Stack(
                children: [
                  if (outfit.bottom != null)
                    Positioned(
                      right: 0,
                      child: ClothingCardMini(item: outfit.bottom!, size: 50),
                    ),
                  if (outfit.top != null)
                    Positioned(
                      left: 0,
                      child: ClothingCardMini(item: outfit.top!, size: 50),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit.occasion,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${outfit.itemCount} items',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
