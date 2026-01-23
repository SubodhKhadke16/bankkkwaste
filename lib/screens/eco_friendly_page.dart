import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../widgets/cart_icon.dart';
import '../widgets/quick_access_row.dart';

/// Displays sustainable living ideas and eco product listings.
class EcoFriendlyPage extends StatelessWidget {
  const EcoFriendlyPage({super.key, this.onNavigateToWasteBank});

  final VoidCallback? onNavigateToWasteBank;

  static final List<_EcoTip> _ecoTips = [
    const _EcoTip(
      title: 'Start Home Composting with Cocopeat',
      description: 'Use cocopeat and coir compost for healthy plant growth.',
      icon: Icons.compost,
    ),
    const _EcoTip(
      title: 'Try Biodegradable Garbage Bags',
      description: 'Reduce plastic waste with compostable garbage bags.',
      icon: Icons.shopping_bag_outlined,
    ),
    const _EcoTip(
      title: 'Go Zero-Waste with Edible Plates',
      description: 'Use edible or areca leaf tableware for eco events.',
      icon: Icons.restaurant_outlined,
    ),
    const _EcoTip(
      title: 'Grow Plants Naturally',
      description: 'Switch to organic compost and coir pots for gardening.',
      icon: Icons.local_florist,
    ),
  ];

  static final List<_EcoProduct> _ecoProducts = [
    const _EcoProduct(
      name: 'Cocopeat Block 1kg',
      tag: 'Organic',
      price: 150,
      icon: Icons.grass,
      imagePath: 'assets/images/compressed-coco-peat.png',
    ),
    const _EcoProduct(
      name: 'Coir Compost Mix',
      tag: 'Compost',
      price: 180,
      icon: Icons.eco,
      imagePath: 'assets/images/coco-coir-in-hands-scaled.jpg',
    ),
    const _EcoProduct(
      name: 'Biodegradable Garbage Bags',
      tag: 'Compostable',
      price: 120,
      icon: Icons.shopping_bag,
      imagePath: 'assets/images/biodegrad-bag.jpg',
    ),
    const _EcoProduct(
      name: 'Edible Rice Plates (Pack of 10)',
      tag: 'Edible',
      price: 200,
      icon: Icons.restaurant,
      imagePath: 'assets/images/edible-rice-plates.jpg',
    ),
    const _EcoProduct(
      name: 'Areca Leaf Bowls (Pack of 25)',
      tag: 'Compostable',
      price: 250,
      icon: Icons.rice_bowl,
      imagePath: 'assets/images/eco-friendly-areca-leaf-bowl.jpeg',
    ),
    const _EcoProduct(
      name: 'Bamboo Toothbrush',
      tag: 'Reusable',
      price: 100,
      icon: Icons.brush,
      imagePath: 'assets/images/bamboo-toothbrush.jpg',
    ),
    const _EcoProduct(
      name: 'Recycled Planters',
      tag: 'Recycled',
      price: 180,
      icon: Icons.local_florist,
      imagePath: 'assets/images/recycled-planters.jpg',
    ),
    const _EcoProduct(
      name: 'Coir Pots (Pack of 5)',
      tag: 'Compostable',
      price: 220,
      icon: Icons.yard,
      imagePath: 'assets/images/coir-pots.jpg',
    ),
    const _EcoProduct(
      name: 'Bio Enzyme Cleaner',
      tag: 'Natural',
      price: 190,
      icon: Icons.cleaning_services,
      imagePath: 'assets/images/bio-enzyme-cleaner.jpg',
    ),
    const _EcoProduct(
      name: 'Cloth Shopping Bag',
      tag: 'Reusable',
      price: 130,
      icon: Icons.local_mall,
      imagePath: 'assets/images/cloth-shopping-bag.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  QuickAccessRow(
                    current: QuickNavTarget.ecoFriendly,
                    onNavigateToWasteBank: onNavigateToWasteBank ?? () {},
                    onNavigateToEcoFriendly: null,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sustainable Living',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSustainableTips(context),
                        const SizedBox(height: 20),
                        const Text(
                          'Eco Product Sales',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildProductGrid(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildSustainableTips(BuildContext context) => SizedBox(
        height: 200,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final tip = _ecoTips[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onTipTap(context, tip),
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  width: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade50,
                        Colors.green.shade100,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(tip.icon, color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        tip.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          tip.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.7),
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemCount: _ecoTips.length,
        ),
      );

  Widget _buildProductGrid(BuildContext context) => GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _ecoProducts
            .map((product) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onProductTap(context, product),
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                              ),
                            ),
                            child: Image.asset(
                              product.imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      product.tag,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${product.price}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      );

  void _onTipTap(BuildContext context, _EcoTip tip) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tip.title),
        content: Text(tip.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onProductTap(BuildContext context, _EcoProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }
}

/// Basic placeholder to confirm navigation from product cards.
class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({required this.product, super.key});

  final _EcoProduct product;

  @override
  Widget build(BuildContext context) {
    // Convert _EcoProduct to Product model for cart
    final productModel = Product(
      id: product.name.toLowerCase().replaceAll(' ', '_'),
      name: product.name,
      description: 'Eco-friendly ${product.tag.toLowerCase()} product',
      price: product.price.toDouble(),
      imageUrl: product.imagePath,
      category: product.tag,
      stock: 100,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        actions: const [
          CartIcon(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.2)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          product.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              product.icon,
                              size: 80,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.tag,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '₹${product.price}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00A86B),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'About this product',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Eco-friendly and sustainable product perfect for your green lifestyle. Help reduce environmental impact while enjoying quality products.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    Consumer<CartService>(
                      builder: (context, cartService, child) {
                        final isInCart = cartService.isInCart(productModel.id);
                        final quantity =
                            cartService.getQuantity(productModel.id);

                        return Column(
                          children: [
                            if (isInCart)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF00A86B),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Added to cart ($quantity)',
                                      style: const TextStyle(
                                        color: Color(0xFF00A86B),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 80),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Add to Cart button
            Consumer<CartService>(
              builder: (context, cartService, child) {
                final isInCart = cartService.isInCart(productModel.id);

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          cartService.addToCart(productModel);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              backgroundColor: const Color(0xFF00A86B),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(isInCart
                            ? Icons.shopping_cart
                            : Icons.shopping_cart_outlined),
                        label: Text(
                          isInCart ? 'Add More to Cart' : 'Add to Cart',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A86B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EcoTip {
  const _EcoTip({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class _EcoProduct {
  const _EcoProduct({
    required this.name,
    required this.tag,
    required this.price,
    required this.icon,
    required this.imagePath,
  });

  final String name;
  final String tag;
  final int price;
  final IconData icon;
  final String imagePath;
}
