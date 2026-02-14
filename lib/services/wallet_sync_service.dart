import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_service.dart';
import 'transaction_service.dart';

/// Service to automatically sync wallet credits for completed waste bank orders
class WalletSyncService {
  static final _firestore = FirebaseFirestore.instance;
  static final Map<String, bool> _syncInProgress = {};

  /// Sync wallet for all completed waste bank orders
  /// Automatically credits wallet for any completed order that hasn't been credited yet
  static Future<void> syncCompletedOrders(String userId) async {
    // Prevent concurrent syncs for the same user
    if (_syncInProgress[userId] == true) {
      print('⏸️ Sync already in progress for user: $userId, skipping');
      return;
    }

    _syncInProgress[userId] = true;
    
    try {
      print('🔄 Starting wallet sync for user: $userId');
      
      // Get user email from Firestore
      String? userEmail;
      try {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          userEmail = userDoc.data()?['email'] as String?;
          print('📧 User email: ${userEmail ?? "Not found"}');
        }
      } catch (e) {
        print('⚠️ Could not fetch user email: $e');
      }
      
      // Get all waste bank orders for user
      final orders = await OrderService.getUserWasteBankOrders(userId);
      print('📦 Found ${orders.length} waste bank orders');

      // Filter completed/delivered orders (case-insensitive)
      final completedOrders = orders.where((order) {
        final status = order.status.toLowerCase().trim();
        final isCompleted = status == 'completed' || 
                           status == 'delivered' || 
                           status == 'picked up' ||
                           status == 'picked';
        if (isCompleted) {
          print('✅ Order ${order.id} has status: ${order.status}');
        }
        return isCompleted;
      }).toList();

      print('✅ Found ${completedOrders.length} completed/delivered orders');
      if (completedOrders.isEmpty) {
        print('⚠️ No completed orders to process');
        return;
      }

      // Get all existing transactions for this user
      final transactions =
          await TransactionService.getUserTransactions(userId);
      final creditedOrderIds =
          transactions.map((t) => t.orderId).where((id) => id != null).toSet();
      
      print('💳 Found ${creditedOrderIds.length} already credited orders');

      // Credit wallet for orders that haven't been credited yet
      for (final order in completedOrders) {
        if (!creditedOrderIds.contains(order.id)) {
          print('💰 Crediting ₹${order.totalAmount} for order ${order.id}');
          
          // This order is completed but hasn't been credited yet
          final transactionId = await TransactionService.creditWalletFromOrder(
            userId: order.userId,
            amount: order.totalAmount,
            orderId: order.id,
            userEmail: userEmail,
            description:
                'Waste Bank Pickup Complete - ${order.itemCount} items collected',
          );
          
          if (transactionId != null) {
            print('✅ Successfully credited wallet: ₹${order.totalAmount} for order ${order.id}');
          } else {
            print('❌ Failed to credit wallet for order ${order.id}');
          }
        } else {
          print('⏭️ Order ${order.id} already credited, skipping');
        }
      }
      
      print('✅ Wallet sync completed');
    } catch (e, stackTrace) {
      print('❌ Error syncing wallet: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _syncInProgress[userId] = false;
    }
  }

  /// Stream that auto-syncs whenever waste bank orders change
  static Stream<void> autoSyncStream(String userId) async* {
    await for (final _ in _firestore
        .collection('waste_bank_orders')
        .where('userId', isEqualTo: userId)
        .snapshots()) {
      await syncCompletedOrders(userId);
      yield null;
    }
  }
}
