import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import '../models/order.dart';

class OrderService {
  static final _firestore = firestore.FirebaseFirestore.instance;
  static final _ordersCollection = _firestore.collection('orders');

  /// Create a new order in Firestore
  static Future<String?> createOrder(Order order) async {
    try {
      final docRef = await _ordersCollection.add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  /// Get all orders for a specific user
  static Future<List<Order>> getUserOrders(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  /// Get a specific order by ID
  static Future<Order?> getOrder(String orderId) async {
    try {
      final doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return Order.fromFirestore(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  /// Update order status
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Get orders by status
  static Future<List<Order>> getOrdersByStatus(
    String userId,
    String status,
  ) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching orders by status: $e');
      return [];
    }
  }

  /// Stream of user orders (real-time updates)
  static Stream<List<Order>> getUserOrdersStream(String userId) => _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Order.fromFirestore(doc.id, doc.data()))
            .toList());

  /// Delete an order
  static Future<bool> deleteOrder(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).delete();
      return true;
    } catch (e) {
      print('Error deleting order: $e');
      return false;
    }
  }

  /// Get order statistics for a user
  static Future<Map<String, dynamic>> getUserOrderStats(String userId) async {
    try {
      final snapshot =
          await _ordersCollection.where('userId', isEqualTo: userId).get();

      final orders = snapshot.docs
          .map((doc) => Order.fromFirestore(doc.id, doc.data()))
          .toList();

      final totalOrders = orders.length;
      final totalSpent =
          orders.fold<double>(0, (sum, order) => sum + order.totalAmount);
      final pendingOrders =
          orders.where((order) => order.status == 'pending').length;
      final completedOrders =
          orders.where((order) => order.status == 'delivered').length;

      return {
        'totalOrders': totalOrders,
        'totalSpent': totalSpent,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
      };
    } catch (e) {
      print('Error fetching order stats: $e');
      return {
        'totalOrders': 0,
        'totalSpent': 0.0,
        'pendingOrders': 0,
        'completedOrders': 0,
      };
    }
  }
}
