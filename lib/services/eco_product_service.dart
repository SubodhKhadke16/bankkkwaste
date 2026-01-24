import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class EcoProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'eco_products';

  /// Get all eco-friendly products from Firestore
  static Stream<List<Product>> getEcoProducts() {
    return _firestore
        .collection(_collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  /// Get eco products as a future (one-time fetch)
  static Future<List<Product>> getEcoProductsOnce() async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .get();
    
    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  /// Add a new eco product to Firestore
  static Future<void> addEcoProduct({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required String category,
    required int stock,
  }) async {
    await _firestore.collection(_collectionName).add({
      'name': name,
      'description': description,
      'price': price,
      'imageURL': imageUrl,
      'category': category,
      'stock': stock,
      'created-at': FieldValue.serverTimestamp(),
    });
  }

  /// Update an existing eco product
  static Future<void> updateEcoProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    int? stock,
  }) async {
    final updates = <String, dynamic>{};
    
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (price != null) updates['price'] = price;
    if (imageUrl != null) updates['imageURL'] = imageUrl;
    if (category != null) updates['category'] = category;
    if (stock != null) updates['stock'] = stock;

    if (updates.isNotEmpty) {
      await _firestore.collection(_collectionName).doc(productId).update(updates);
    }
  }

  /// Delete an eco product
  static Future<void> deleteEcoProduct(String productId) async {
    await _firestore.collection(_collectionName).doc(productId).delete();
  }
}
