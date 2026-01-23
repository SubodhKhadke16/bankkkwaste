import 'package:cloud_firestore/cloud_firestore.dart';

class Product {

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    this.createdAt,
  });

  factory Product.fromFirestore(String id, Map<String, dynamic> data) => Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: _parseDouble(data['price']),
      imageUrl: data['imageURL'] ?? '',
      category: data['category'] ?? '',
      stock: _parseInt(data['stock']),
      createdAt: data['created-at'] is Timestamp 
          ? (data['created-at'] as Timestamp).toDate() 
          : null,
    );

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final DateTime? createdAt;
}
