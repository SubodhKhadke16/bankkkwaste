import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  static final _firestore = FirebaseFirestore.instance;
  static final _productsCollection = _firestore.collection('products');

  static Future<List<Product>> fetchProducts() async {
    try {
      final snapshot = await _productsCollection.get();
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // Add sample products to Firebase (from Eco-Friendly Page & Waste Bank Data)
  static Future<void> addSampleProducts() async {
    try {
      final sampleProducts = [
        // Eco-Friendly Products
        {
          'name': 'Cocopeat Block 1kg',
          'description': 'Use cocopeat and coir compost for healthy plant growth. Perfect for organic gardening.',
          'price': 150.0,
          'imageURL': 'assets/images/compressed-coco-peat.png',
          'category': 'Organic',
          'stock': 100,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Coir Compost Mix',
          'description': 'Natural compost mix for sustainable gardening and healthy plants.',
          'price': 180.0,
          'imageURL': 'assets/images/coco-coir-in-hands-scaled.jpg',
          'category': 'Compost',
          'stock': 85,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Biodegradable Garbage Bags',
          'description': 'Reduce plastic waste with compostable garbage bags. Eco-friendly alternative.',
          'price': 120.0,
          'imageURL': 'assets/images/biodegrad-bag.jpg',
          'category': 'Compostable',
          'stock': 200,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Edible Rice Plates (Pack of 10)',
          'description': 'Use edible or areca leaf tableware for eco events. Zero waste solution.',
          'price': 200.0,
          'imageURL': 'assets/images/edible-rice-plates.jpg',
          'category': 'Edible',
          'stock': 150,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Areca Leaf Bowls (Pack of 25)',
          'description': 'Natural, compostable bowls made from areca leaves. Perfect for parties.',
          'price': 250.0,
          'imageURL': 'assets/images/eco-friendly-areca-leaf-bowl.jpeg',
          'category': 'Compostable',
          'stock': 120,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Bamboo Toothbrush',
          'description': 'Eco-friendly bamboo toothbrush. Biodegradable and sustainable.',
          'price': 100.0,
          'imageURL': 'assets/images/bamboo-toothbrush.jpg',
          'category': 'Reusable',
          'stock': 300,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Recycled Planters',
          'description': 'Beautiful planters made from recycled materials. Sustainable home decor.',
          'price': 180.0,
          'imageURL': 'assets/images/recycled-planters.jpg',
          'category': 'Recycled',
          'stock': 90,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Coir Pots (Pack of 5)',
          'description': 'Switch to organic compost and coir pots for gardening. Fully compostable.',
          'price': 220.0,
          'imageURL': 'assets/images/coir-pots.jpg',
          'category': 'Compostable',
          'stock': 110,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Bio Enzyme Cleaner',
          'description': 'Natural cleaning solution made from bio enzymes. Chemical-free and eco-friendly.',
          'price': 190.0,
          'imageURL': 'assets/images/bio-enzyme-cleaner.jpg',
          'category': 'Natural',
          'stock': 75,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Cloth Shopping Bag',
          'description': 'Durable reusable shopping bag. Reduce single-use plastic waste.',
          'price': 130.0,
          'imageURL': 'assets/images/cloth-shopping-bag.jpg',
          'category': 'Reusable',
          'stock': 250,
          'created-at': FieldValue.serverTimestamp(),
        },
        // Recyclable Materials (from Waste Bank trending rates)
        {
          'name': 'Paper Scrap Collection',
          'description': 'Sell your paper waste. We offer competitive rates for paper recycling.',
          'price': 6.0,
          'imageURL': 'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?w=500',
          'category': 'Paper',
          'stock': 999,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Plastic Waste Collection',
          'description': 'Plastic recycling service. Help reduce plastic pollution.',
          'price': 2.0,
          'imageURL': 'https://images.unsplash.com/photo-1621451537084-482c73073a0f?w=500',
          'category': 'Plastic',
          'stock': 999,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Metal Scrap Collection',
          'description': 'Metal recycling service. We buy all types of metal waste.',
          'price': 17.0,
          'imageURL': 'https://images.unsplash.com/photo-1625667089595-141f82ccb80a?w=500',
          'category': 'Metal',
          'stock': 999,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'E-Waste Collection',
          'description': 'Safe disposal of electronic waste. Get paid for your old electronics.',
          'price': 10.0,
          'imageURL': 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=500',
          'category': 'E-Waste',
          'stock': 999,
          'created-at': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Newspaper Collection',
          'description': 'Old newspaper recycling. Competitive rates for bulk quantities.',
          'price': 7.0,
          'imageURL': 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=500',
          'category': 'Paper',
          'stock': 999,
          'created-at': FieldValue.serverTimestamp(),
        },
      ];

      final batch = _firestore.batch();
      for (final product in sampleProducts) {
        final docRef = _productsCollection.doc();
        batch.set(docRef, product);
      }
      await batch.commit();
      print('Successfully added ${sampleProducts.length} sample products!');
    } catch (e) {
      print('Error adding sample products: $e');
    }
  }

  // Check if products exist, if not add sample products
  static Future<void> initializeProducts() async {
    try {
      final snapshot = await _productsCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        print('No products found. Adding sample products...');
        await addSampleProducts();
      }
    } catch (e) {
      print('Error initializing products: $e');
    }
  }
}
