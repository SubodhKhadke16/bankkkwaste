import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import '../models/order.dart';
import 'transaction_service.dart';

class OrderService {
  static final _firestore = firestore.FirebaseFirestore.instance;
  static final _ordersCollection = _firestore.collection('orders');
  static final _wasteBankOrdersCollection =
      _firestore.collection('waste_bank_orders');

  /// Create a new order in Firestore
  static Future<String?> createOrder(Order order) async {
    try {
      // Use separate collection for waste bank orders
      final collection =
          order.isWasteBankOrder ? _wasteBankOrdersCollection : _ordersCollection;
      final docRef = await collection.add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  /// Create a waste bank pickup order
  static Future<String?> createWasteBankOrder(Order order) async {
    try {
      final docRef = await _wasteBankOrdersCollection.add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating waste bank order: $e');
      return null;
    }
  }

  /// Get all orders for a specific user (both regular and waste bank)
  static Future<List<Order>> getUserOrders(String userId) async {
    try {
      // Get regular orders
      final ordersSnapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = ordersSnapshot.docs
          .map((doc) => Order.fromFirestore(doc.id, doc.data()))
          .toList();

      // Get waste bank orders
      final wasteBankSnapshot = await _wasteBankOrdersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final wasteBankOrders = wasteBankSnapshot.docs
          .map((doc) => Order.fromFirestore(doc.id, doc.data()))
          .toList();

      // Combine and sort by date
      final allOrders = [...orders, ...wasteBankOrders];
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return allOrders;
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  /// Get only waste bank orders for a user
  static Future<List<Order>> getUserWasteBankOrders(String userId) async {
    try {
      final snapshot = await _wasteBankOrdersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching waste bank orders: $e');
      return [];
    }
  }

  /// Get only eco-friendly orders for a user
  static Future<List<Order>> getUserEcoOrders(String userId) async {
    try {
      final snapshot = await _ordersCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching eco orders: $e');
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
  /// Automatically credits wallet when waste bank order is completed
  static Future<bool> updateOrderStatus(
    String orderId,
    String status, {
    bool isWasteBankOrder = false,
  }) async {
    try {
      final collection =
          isWasteBankOrder ? _wasteBankOrdersCollection : _ordersCollection;

      await collection.doc(orderId).update({
        'status': status,
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });

      // If waste bank order is completed, credit money to wallet
      if (isWasteBankOrder && status == 'completed') {
        final order = await _getWasteBankOrder(orderId);
        if (order != null) {
          // Get user email
          String? userEmail;
          try {
            final userDoc = await _firestore.collection('users').doc(order.userId).get();
            if (userDoc.exists) {
              userEmail = userDoc.data()?['email'] as String?;
            }
          } catch (e) {
            print('⚠️ Could not fetch user email: $e');
          }
          
          await TransactionService.creditWalletFromOrder(
            userId: order.userId,
            amount: order.totalAmount,
            orderId: orderId,
            userEmail: userEmail,
            description:
                'Waste Bank Pickup Complete - ${order.itemCount} items collected',
          );
        }
      }

      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// Get a specific waste bank order by ID (private helper)
  static Future<Order?> _getWasteBankOrder(String orderId) async {
    try {
      final doc = await _wasteBankOrdersCollection.doc(orderId).get();
      if (doc.exists) {
        return Order.fromFirestore(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching waste bank order: $e');
      return null;
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
