import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lookbook_provider.dart';
import '../providers/wardrobe_provider.dart';
import '../models/saved_outfit.dart';
import '../models/clothing_item.dart';
import '../utils/theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/clothing_card.dart';

class LookbookScreen extends StatefulWidget {
  const LookbookScreen({super.key});

  @override
  State<LookbookScreen> createState() => _LookbookScreenState();
}

class _LookbookScreenState extends State<LookbookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LookbookProvider>().loadSavedOutfits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Lookbook Của Tôi'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFCE7F3), AppTheme.backgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Consumer2<LookbookProvider, WardrobeProvider>(
        builder: (context, lookbook, wardrobe, _) {
          if (lookbook.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (lookbook.savedOutfits.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'Lookbook Trống',
              subtitle: 'Hãy lưu các set đồ từ gợi ý AI hoặc quẹt outfit nhé!',
              action: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lookbook.savedOutfits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final outfit = lookbook.savedOutfits[index];
              return _SavedOutfitCard(outfit: outfit, wardrobe: wardrobe);
            },
          );
        },
      ),
    );
  }
}

class _SavedOutfitCard extends StatelessWidget {
  final SavedOutfit outfit;
  final WardrobeProvider wardrobe;

  const _SavedOutfitCard({required this.outfit, required this.wardrobe});

  @override
  Widget build(BuildContext context) {
    final top = _getItem(outfit.topId);
    final bottom = _getItem(outfit.bottomId);
    final outerwear = _getItem(outfit.outerwearId);
    final shoes = _getItem(outfit.footwearId);
    
    final List<ClothingItem> accessories = [];
    for (final accId in outfit.accessoryIds) {
      final acc = _getItem(accId);
      if (acc != null) accessories.add(acc);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    outfit.source == 'tinder' ? Icons.local_fire_department : Icons.auto_awesome,
                    color: outfit.source == 'tinder' ? Colors.pink : AppTheme.accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    outfit.name ?? 'Set đồ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                onPressed: () => _confirmDelete(context),
                tooltip: 'Xóa',
              ),
            ],
          ),
          
          Text(
            _formatDate(outfit.createdAt),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Items grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (top != null) _buildItemWithLabel(top, 'Áo'),
              if (bottom != null) _buildItemWithLabel(bottom, 'Quần/Váy'),
              if (outerwear != null) _buildItemWithLabel(outerwear, 'Khoác'),
              if (shoes != null) _buildItemWithLabel(shoes, 'Giày'),
              ...accessories.map((item) => _buildItemWithLabel(item, 'Phụ kiện')),
            ],
          ),
        ],
      ),
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

  ClothingItem? _getItem(String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return wardrobe.allItems.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa Set đồ này?'),
        content: const Text('Bạn có chắc chắn muốn xóa set đồ này khỏi Lookbook?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<LookbookProvider>().deleteOutfit(outfit.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
