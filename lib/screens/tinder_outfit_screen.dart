import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:confetti/confetti.dart';

import '../models/clothing_item.dart';
import '../providers/wardrobe_provider.dart';
import '../providers/lookbook_provider.dart';
import '../utils/theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/clothing_card.dart';

class TinderOutfitScreen extends StatefulWidget {
  const TinderOutfitScreen({super.key});

  @override
  State<TinderOutfitScreen> createState() => _TinderOutfitScreenState();
}

class _TinderOutfitScreenState extends State<TinderOutfitScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  late ConfettiController _confettiController;
  
  List<List<ClothingItem>> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRandomOutfits();
    });
  }

  @override
  void dispose() {
    _swiperController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _loadRandomOutfits() {
    final wardrobe = context.read<WardrobeProvider>();
    final allItems = wardrobe.allItems;
    
    final tops = allItems.where((i) => i.type.category == 'top').toList();
    final bottoms = allItems.where((i) => i.type.category == 'bottom').toList();
    final shoes = allItems.where((i) => i.type.category == 'footwear').toList();
    
    if (tops.isEmpty || bottoms.isEmpty || shoes.isEmpty) {
      setState(() {
        _cards = [];
        _isLoading = false;
      });
      return;
    }

    final random = math.Random();
    final List<List<ClothingItem>> outfits = [];
    
    // Generate 20 random combinations with smart rules
    for (int i = 0; i < 20; i++) {
      ClothingItem? selectedTop;
      ClothingItem? selectedBottom;
      ClothingItem? selectedShoes;

      for (int attempt = 0; attempt < 50; attempt++) {
        final top = tops[random.nextInt(tops.length)];
        final bottom = bottoms[random.nextInt(bottoms.length)];
        final shoe = shoes[random.nextInt(shoes.length)];

        if (_isCombinationValid(top, bottom, shoe) || attempt == 49) {
          selectedTop = top;
          selectedBottom = bottom;
          selectedShoes = shoe;
          break;
        }
      }

      if (selectedTop != null && selectedBottom != null && selectedShoes != null) {
        outfits.add([selectedTop, selectedBottom, selectedShoes]);
      }
    }

    setState(() {
      _cards = outfits;
      _isLoading = false;
    });
  }

  bool _isCombinationValid(ClothingItem top, ClothingItem bottom, ClothingItem shoes) {
    final isFormalTop = top.type == ClothingType.shirt || top.styles.contains(ClothingStyle.formal) || top.styles.contains(ClothingStyle.elegant);
    final isCasualTop = top.type == ClothingType.tshirt || top.type == ClothingType.hoodie || top.styles.contains(ClothingStyle.sporty);
    
    final isCasualBottom = bottom.type == ClothingType.shorts || bottom.styles.contains(ClothingStyle.sporty);
    
    final isFormalShoes = shoes.type == ClothingType.shoes || shoes.styles.contains(ClothingStyle.formal) || shoes.styles.contains(ClothingStyle.elegant);

    // Rule 1: No casual top (tshirt/hoodie) + formal shoes (leather shoes)
    if (isCasualTop && isFormalShoes) return false;

    // Rule 2: No formal top (shirt) + very casual bottom (shorts/sporty)
    if (isFormalTop && isCasualBottom) return false;

    // Rule 3: No shorts with formal shoes
    if (bottom.type == ClothingType.shorts && isFormalShoes) return false;

    return true;
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (direction == CardSwiperDirection.right) {
      final outfit = _cards[previousIndex];
      final lookbook = context.read<LookbookProvider>();
      lookbook.saveOutfit(
        topId: outfit[0].id,
        bottomId: outfit[1].id,
        footwearId: outfit[2].id,
        source: 'tinder',
        name: 'Tinder Mix',
      );

      // Bắn pháo hoa khi quẹt phải (Thích)
      _confettiController.play();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã lưu vào Lookbook của bạn! 💖'),
          backgroundColor: Colors.pink.shade400,
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
    return true; // Cho phép swipe
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Quẹt Outfit 🔥'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEDE9FE), AppTheme.backgroundColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildBody(),
          
          // Pháo hoa ở giữa màn hình
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive, // Bắn ra mọi hướng
              shouldLoop: false,
              colors: const [
                Colors.pink,
                Colors.purple,
                Colors.blue,
                Colors.yellow,
              ],
              numberOfParticles: 30,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: EmptyState(
            icon: Icons.checkroom,
            title: 'Chưa đủ đồ',
            subtitle: 'Bạn cần ít nhất 1 Áo, 1 Quần/Váy và 1 Giày để mix đồ!',
            action: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Quay lại'),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Quẹt TRÁI để Bỏ qua • Quẹt PHẢI để Lưu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: CardSwiper(
            controller: _swiperController,
            cardsCount: _cards.length,
            onSwipe: _onSwipe,
            onEnd: () {
              // Hết bài thì load lại random
              _loadRandomOutfits();
            },
            padding: const EdgeInsets.all(24.0),
            cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
              final outfit = _cards[index];
              return _buildOutfitCard(outfit);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: Icons.close_rounded,
                color: Colors.red.shade400,
                onTap: () => _swiperController.swipe(CardSwiperDirection.left),
              ),
              const SizedBox(width: 40),
              _buildControlButton(
                icon: Icons.favorite_rounded,
                color: Colors.pink.shade400,
                onTap: () => _swiperController.swipe(CardSwiperDirection.right),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOutfitCard(List<ClothingItem> outfit) {
    // outfit có 3 món: Top, Bottom, Shoes
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: const Center(
              child: Text(
                'Gợi ý Mix & Match',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Cột trái: Áo và Giày
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildItemImage(outfit[0]), // Áo
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 1,
                          child: _buildItemImage(outfit[2]), // Giày
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Cột phải: Quần
                  Expanded(
                    flex: 1,
                    child: _buildItemImage(outfit[1]), // Quần
                  ),
                ],
              ),
            ),
          ),
          
          // Thẻ thông tin bên dưới
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.style, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'Phong cách: ${outfit[0].styles.isNotEmpty ? outfit[0].styles.first.displayName : "Casual"}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.palette, size: 16, color: AppTheme.accentColor),
                    const SizedBox(width: 6),
                    Text(
                      'Tone màu chính: ${outfit[0].color}',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItemImage(ClothingItem item) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClothingImage(
            item: item,
            fit: BoxFit.cover,
            errorWidget: Container(
              color: Colors.grey.shade100,
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          // Gradient tối nhẹ ở dưới để nổi chữ
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(
                item.type.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: color, size: 32),
      ),
    );
  }
}
