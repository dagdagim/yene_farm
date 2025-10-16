import 'package:flutter/material.dart';
import 'package:yene_farm/models/product_model.dart';
import 'package:yene_farm/utils/colors.dart';
import 'package:yene_farm/utils/constants.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final bool showActions;

  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.showActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section
            Stack(
              children: [
                // Product Image Container
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: YeneFarmColors.primaryGreen.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.cardBorderRadius),
                      topRight: Radius.circular(AppConstants.cardBorderRadius),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getProductIcon(product.category),
                        size: 60,
                        color: YeneFarmColors.primaryGreen.withOpacity(0.7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.category,
                        style: const TextStyle(
                          color: YeneFarmColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Organic Badge
                if (product.isOrganic)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: YeneFarmColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: YeneFarmColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Organic',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Rating Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: Colors.yellow),
                        const SizedBox(width: 4),
                        Text(
                          product.farmerRating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: YeneFarmColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'ETB ${product.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: YeneFarmColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Farmer Name and Location
                  Row(
                    children: [
                      const Icon(Icons.person_rounded, size: 14, color: YeneFarmColors.textLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.farmerName,
                          style: const TextStyle(
                            color: YeneFarmColors.textMedium,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on_rounded, size: 14, color: YeneFarmColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        product.location,
                        style: const TextStyle(
                          color: YeneFarmColors.textMedium,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    product.description,
                    style: const TextStyle(
                      color: YeneFarmColors.textMedium,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Quantity and Unit
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: YeneFarmColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.scale_rounded, size: 14, color: YeneFarmColors.primaryGreen),
                        const SizedBox(width: 6),
                        Text(
                          '${product.quantity} ${product.unit} available',
                          style: const TextStyle(
                            color: YeneFarmColors.primaryGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Action Buttons
                  if (showActions)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: YeneFarmColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                              ),
                            ),
                            child: const Text('Buy Now'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border.all(color: YeneFarmColors.primaryGreen),
                            borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chat_rounded, color: YeneFarmColors.primaryGreen),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cereals':
        return Icons.grain_rounded;
      case 'coffee':
        return Icons.coffee_rounded;
      case 'vegetables':
        return Icons.eco_rounded;
      case 'fruits':
        return Icons.apple_rounded;
      case 'spices':
        return Icons.spa_rounded;
      case 'legumes':
        return Icons.grass_rounded;
      case 'oil seeds':
        return Icons.water_drop_rounded;
      default:
        return Icons.agriculture_rounded;
    }
  }
}