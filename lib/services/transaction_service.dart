import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction.dart';
import 'user_service.dart';

class TransactionService {
  static final _firestore = FirebaseFirestore.instance;
  static final _transactionsCollection = _firestore.collection('transactions');

  /// Create a new transaction and update wallet balance
  static Future<String?> createTransaction({
    required String userId,
    required double amount,
    required String type, // 'credit' or 'debit'
    String? userEmail,
    String? description,
    String? orderId,
    String? category,
  }) async {
    try {
      print('📝 Creating transaction for user: $userId');
      print('   Email: ${userEmail ?? "N/A"}');
      print('   Type: $type, Amount: ₹$amount');
      print('   Order ID: ${orderId ?? "N/A"}');
      print('   Description: ${description ?? "N/A"}');
      
      // Create transaction record
      final transaction = WalletTransaction(
        id: '',
        userId: userId,
        amount: amount,
        type: type,
        status: 'completed',
        createdAt: DateTime.now(),
        userEmail: userEmail,
        description: description,
        orderId: orderId,
        category: category,
      );

      final docRef =
          await _transactionsCollection.add(transaction.toFirestore());
      print('✅ Transaction created with ID: ${docRef.id}');

      // Update user wallet balance
      final isAdd = type == 'credit';
      final balanceUpdated = await UserService.updateWalletBalance(userId, amount, isAdd: isAdd);
      
      if (!balanceUpdated) {
        print('⚠️ Wallet balance update failed, but transaction was created');
      }

      return docRef.id;
    } catch (e) {
      print('❌ Error creating transaction: $e');
      return null;
    }
  }

  /// Credit money to wallet (for completed waste bank orders)
  static Future<String?> creditWalletFromOrder({
    required String userId,
    required double amount,
    required String orderId,
    String? userEmail,
    String? description,
  }) async =>
      createTransaction(
        userId: userId,
        amount: amount,
        type: 'credit',
        userEmail: userEmail,
        description: description ?? 'Waste Bank Pickup - Payment Received',
        orderId: orderId,
        category: 'waste_bank',
      );

  /// Debit money from wallet (for eco-friendly purchases)
  static Future<String?> debitWalletForPurchase({
    required String userId,
    required double amount,
    required String orderId,
    String? userEmail,
    String? description,
  }) async =>
      createTransaction(
        userId: userId,
        amount: amount,
        type: 'debit',
        userEmail: userEmail,
        description: description ?? 'Eco-Friendly Product Purchase',
        orderId: orderId,
        category: 'eco_friendly',
      );

  /// Add money to wallet
  static Future<String?> addMoney({
    required String userId,
    required double amount,
    String? userEmail,
    String? paymentMethod,
  }) async =>
      createTransaction(
        userId: userId,
        amount: amount,
        type: 'credit',
        userEmail: userEmail,
        description: paymentMethod != null
            ? 'Money Added via $paymentMethod'
            : 'Money Added to Wallet',
        category: 'add_money',
      );

  /// Withdraw money from wallet
  static Future<String?> withdrawMoney({
    required String userId,
    required double amount,
    String? bankAccount,
  }) async =>
      createTransaction(
        userId: userId,
        amount: amount,
        type: 'debit',
        description: bankAccount != null
            ? 'Withdrawal to $bankAccount'
            : 'Withdrawal from Wallet',
        category: 'withdrawal',
      );

  /// Get all transactions for a user
  static Future<List<WalletTransaction>> getUserTransactions(
    String userId, {
    int? limit,
  }) async {
    try {
      var query = _transactionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => WalletTransaction.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  /// Get transactions by type (credit or debit)
  static Future<List<WalletTransaction>> getTransactionsByType(
    String userId,
    String type,
  ) async {
    try {
      final snapshot = await _transactionsCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WalletTransaction.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching transactions by type: $e');
      return [];
    }
  }

  /// Get transactions by category
  static Future<List<WalletTransaction>> getTransactionsByCategory(
    String userId,
    String category,
  ) async {
    try {
      final snapshot = await _transactionsCollection
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => WalletTransaction.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching transactions by category: $e');
      return [];
    }
  }

  /// Get transaction stream for real-time updates
  static Stream<List<WalletTransaction>> getTransactionsStream(
    String userId, {
    int? limit,
  }) {
    var query = _transactionsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => WalletTransaction.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  /// Get transaction stats for a user
  static Future<Map<String, dynamic>> getTransactionStats(
    String userId,
  ) async {
    try {
      final transactions = await getUserTransactions(userId);

      final totalCredits = transactions
          .where((t) => t.type == 'credit' && t.status == 'completed')
          .fold<double>(0, (sum, t) => sum + t.amount);

      final totalDebits = transactions
          .where((t) => t.type == 'debit' && t.status == 'completed')
          .fold<double>(0, (sum, t) => sum + t.amount);

      final thisMonthTransactions = transactions.where((t) {
        final now = DateTime.now();
        return t.createdAt.year == now.year && t.createdAt.month == now.month;
      }).toList();

      final monthlyEarnings = thisMonthTransactions
          .where((t) => t.type == 'credit' && t.status == 'completed')
          .fold<double>(0, (sum, t) => sum + t.amount);

      final monthlySpending = thisMonthTransactions
          .where((t) => t.type == 'debit' && t.status == 'completed')
          .fold<double>(0, (sum, t) => sum + t.amount);

      return {
        'totalCredits': totalCredits,
        'totalDebits': totalDebits,
        'monthlyEarnings': monthlyEarnings,
        'monthlySpending': monthlySpending,
        'totalTransactions': transactions.length,
      };
    } catch (e) {
      print('Error fetching transaction stats: $e');
      return {
        'totalCredits': 0.0,
        'totalDebits': 0.0,
        'monthlyEarnings': 0.0,
        'monthlySpending': 0.0,
        'totalTransactions': 0,
      };
    }
  }
}
