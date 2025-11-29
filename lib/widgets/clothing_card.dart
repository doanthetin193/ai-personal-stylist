import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/clothing_item.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

/// Widget để hiển thị ảnh từ Base64 hoặc URL
class ClothingImage extends StatelessWidget {
  final ClothingItem item;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ClothingImage({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Ưu tiên Base64 nếu có
    if (item.imageBase64 != null && item.imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(item.imageBase64!);
        return Image.memory(
          bytes,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? _buildErrorWidget();
          },
        );
      } catch (e) {
        return errorWidget ?? _buildErrorWidget();
      }
    }
    
    // Fallback về URL nếu có (backward compatibility)
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: item.imageUrl!,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      );
    }
    
    // Không có ảnh
    return errorWidget ?? _buildErrorWidget();
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.white),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, size: 40),
    );
  }
}

class ClothingCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavorite;
  final bool showFavorite;
  final bool isSelected;

  const ClothingCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.onFavorite,
    this.showFavorite = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: ClothingImage(
                  item: item,
                  fit: BoxFit.cover,
                  placeholder: _buildShimmer(),
                  errorWidget: Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
              ),
              
              // Gradient overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.type.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        getColorNameVN(item.color),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Favorite button
              if (showFavorite)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        item.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: item.isFavorite 
                            ? AppTheme.secondaryColor 
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              
              // Selection check
              if (isSelected)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.white),
    );
  }
}

/// Clothing card nhỏ gọn cho outfit display
class ClothingCardMini extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final double size;

  const ClothingCardMini({
    super.key,
    required this.item,
    this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ClothingImage(
            item: item,
            fit: BoxFit.cover,
            placeholder: Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            errorWidget: Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
      ),
    );
  }
}
