import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  CartService() {
    _loadCart();
  }

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

  /// Save cart to SharedPreferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _items.map((item) => item.toJson()).toList();
      await prefs.setString('cart', jsonEncode(cartData));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  /// Load cart from SharedPreferences
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart');

      if (cartString != null) {
        final List<dynamic> cartData = jsonDecode(cartString);
        _items.clear();
        for (final item in cartData) {
          _items.add(CartItem.fromJson(item));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }
}
