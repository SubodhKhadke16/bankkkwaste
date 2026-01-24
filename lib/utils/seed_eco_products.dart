import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class to populate initial eco-friendly products in Firestore.
/// Run this once to seed the database with sample products.
class SeedEcoProducts {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedProducts() async {
    final products = [
      {
        'name': 'Cocopeat Block 1kg',
        'category': 'Organic',
        'price': 150.0,
        'imageURL': 'assets/images/compressed-coco-peat.png',
        'description':
            'Premium quality cocopeat block perfect for gardening. Eco-friendly growing medium that retains moisture and promotes healthy plant growth.',
        'stock': 50,
        'created-at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Coir Compost Mix',
        'category': 'Compost',
        'price': 180.0,
        'imageURL': 'assets/images/coco-coir-in-hands-scaled.jpg',
        'description':
            'Natural coir compost mix enriched with nutrients. Perfect for sustainable gardening and plant care.',
        'stock': 40,
        'created-at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Biodegradable Garbage Bags',
        'category': 'Compostable',
        'price': 120.0,
        'imageURL': 'assets/images/biodegrad-bag.jpg',
        'description':
            'Eco-friendly biodegradable garbage bags that decompose naturally. Reduce plastic waste in your home.',
        'stock': 100,
        'created-at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Edible Rice Plates (Pack of 10)',
        'category': 'Edible',
        'price': 200.0,
        'imageURL': 'assets/images/edible-rice-plates.jpg',
        'description':
            'Innovative edible plates made from rice. Perfect for eco-friendly events and zero-waste dining.',
        'stock': 75,
        'created-at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Areca Leaf Bowls (Pack of 25)',
        'category': 'Compostable',
        'price': 250.0,
        'imageURL': 'assets/images/eco-friendly-areca-leaf-bowl.jpeg',
        'description':
            'Handcrafted areca leaf bowls. Completely natural and compostable alternative to plastic bowls.',
        'stock': 60,
        'created-at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Bamboo Toothbrush',
        'category': 'Reusable',
        'price': 100.0,
        'imageURL': 'assets/images/bamboo-toothbrush.jpg',
        'description':
            'Sustainable bamboo toothbrush with biodegradable handle. Make your daily routine eco-friendly.',
        'stock': 120,
        'created-at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Recycled Planters',
        'category': 'Recycled',
        'price': 180.0,
        'imageURL': 'assets/images/recycled-planters.jpg',
        'description':
            'Beautiful planters made from recycled materials. Stylish and sustainable home decor.',
        'stock': 45,
        'created-at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Coir Pots (Pack of 5)',
        'category': 'Compostable',
        'price': 220.0,
        'imageURL': 'assets/images/coir-pots.jpg',
        'description':
            'Biodegradable coir pots for seedlings. Plant directly in soil without removing the pot.',
        'stock': 55,
        'created-at': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Bio Enzyme Cleaner',
        'category': 'Natural',
        'price': 190.0,
        'imageURL': 'assets/images/bio-enzyme-cleaner.jpg',
        'description':
            'Natural bio enzyme cleaner made from citrus peels. Chemical-free cleaning solution.',
        'stock': 80,
        'created-at': FieldValue.serverTimestamp(),
      },
    ];

    try {
      for (final product in products) {
        await _firestore.collection('eco_products').add(product);
        print('✅ Added: ${product['name']}');
      }
      print('\n🎉 Successfully seeded ${products.length} eco products!');
    } catch (e) {
      print('❌ Error seeding products: $e');
    }
  }
}
