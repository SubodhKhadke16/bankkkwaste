import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  CartService({this.userId}) {
    _loadCart();
  }

  final String? userId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  /// Add a product to the cart
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    _saveCart();
    notifyListeners();
  }

  /// Remove a product from the cart
  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveCart();
    notifyListeners();
  }

  /// Update quantity of a cart item
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _items[index].quantity = quantity;
      _saveCart();
      notifyListeners();
    }
  }

  /// Increment quantity of a cart item
  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      _items[index].quantity++;
      _saveCart();
      notifyListeners();
    }
  }

  /// Decrement quantity of a cart item
  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        _saveCart();
        notifyListeners();
      } else {
        removeFromCart(productId);
      }
    }
  }

  /// Clear all items from the cart
  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  /// Check if a product is in the cart
  bool isInCart(String productId) =>
      _items.any((item) => item.product.id == productId);

  /// Get quantity of a specific product in cart
  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: Product(
          id: '',
          name: '',
          description: '',
          price: 0,
          imageUrl: '',
          category: '',
          stock: 0,
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  /// Save cart to local storage only (no Firebase sync)
  Future<void> _saveCart() async {
    try {
      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      final cartData = _items.map((item) => item.toJson()).toList();
      await prefs.setString('cart', jsonEncode(cartData));

      // Sync to Firebase if user is logged in
      if (userId != null && userId!.isNotEmpty) {
        await _syncToFirebase();
      }
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  /// Load cart from local storage only
  Future<void> _loadCart() async {
    try {
      debugPrint('🔄 Loading cart...');
      debugPrint('   User ID: ${userId ?? "Not logged in"}');
      
      // First, try to load from Firebase if user is logged in
      if (userId != null && userId!.isNotEmpty) {
        await _loadFromFirebase();
      } else {
        debugPrint('   Loading from local storage (not logged in)');
        // If not logged in, load from local storage
        final prefs = await SharedPreferences.getInstance();
        final cartString = prefs.getString('cart');

        if (cartString != null) {
          final List<dynamic> cartData = jsonDecode(cartString);
          _items.clear();
          for (final item in cartData) {
            _items.add(CartItem.fromJson(item));
          }
          debugPrint('   ✅ Loaded ${_items.length} items from local storage');
          notifyListeners();
        } else {
          debugPrint('   No local cart data found');
        }
      }
    } catch (e) {
      debugPrint('❌ Error loading cart: $e');
    }
  }

  /// Sync cart to Firebase Firestore
  Future<void> _syncToFirebase() async {
    try {
      if (userId == null || userId!.isEmpty) {
        debugPrint('❌ Cannot sync cart - no user ID');
        return;
      }

      final cartData = _items.map((item) => item.toJson()).toList();
      
      debugPrint('📤 Syncing cart to Firebase...');
      debugPrint('   User ID: $userId');
      debugPrint('   Cart items: ${cartData.length}');
      
      await _firestore.collection('carts').doc(userId).set({
        'items': cartData,
        'userId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
        'totalItems': _items.fold(0, (sum, item) => sum + item.quantity),
        'totalAmount': totalAmount,
      });
      
      debugPrint('✅ Cart synced to Firebase successfully!');
      debugPrint('   Path: carts/$userId');
    } catch (e) {
      debugPrint('❌ Error syncing cart to Firebase: $e');
      rethrow;
    }
  }

  /// Manually trigger sync (for testing)
  Future<void> syncNow() async {
    await _syncToFirebase();
  }

  /// Load cart from Firebase Firestore
  Future<void> _loadFromFirebase() async {
    try {
      if (userId == null || userId!.isEmpty) return;

      debugPrint('📥 Loading cart from Firebase...');
      debugPrint('   Path: carts/$userId');
      
      final doc = await _firestore.collection('carts').doc(userId).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('items')) {
          final List<dynamic> cartData = data['items'];
          _items.clear();
          for (final item in cartData) {
            _items.add(CartItem.fromJson(item));
          }
          
          // Also save to local storage for offline access
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('cart', jsonEncode(cartData));
          
          debugPrint('✅ Loaded ${_items.length} items from Firebase');
          notifyListeners();
        } else {
          debugPrint('   No items field found in cart document');
        }
      } else {
        debugPrint('   No cart document found in Firebase');
      }
    } catch (e) {
      debugPrint('❌ Error loading cart from Firebase: $e');
      // Fallback to local storage if Firebase fails
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart');
      if (cartString != null) {
        final List<dynamic> cartData = jsonDecode(cartString);
        _items.clear();
        for (final item in cartData) {
          _items.add(CartItem.fromJson(item));
        }
        debugPrint('   ⚠️  Loaded ${_items.length} items from local storage (fallback)');
        notifyListeners();
      }
    }
  }
}
