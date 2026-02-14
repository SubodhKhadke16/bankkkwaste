import 'package:cloud_firestore/cloud_firestore.dart';

class WalletTransaction {
  WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    this.userEmail,
    this.description,
    this.orderId,
    this.category,
    this.updatedAt,
  });

  factory WalletTransaction.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) =>
      WalletTransaction(
        id: id,
        userId: data['userId'] ?? '',
        amount: (data['amount'] ?? 0).toDouble(),
        type: data['type'] ?? 'credit', // credit or debit
        status: data['status'] ?? 'completed', // pending, completed, failed
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        userEmail: data['userEmail'],
        description: data['description'],
        orderId: data['orderId'],
        category: data['category'], // waste_bank, eco_friendly, withdrawal, etc.
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );

  final String id;
  final String userId;
  final double amount;
  final String type; // credit or debit
  final String status; // pending, completed, failed
  final DateTime createdAt;
  final String? userEmail;
  final String? description;
  final String? orderId; // Reference to order if applicable
  final String? category; // waste_bank, eco_friendly, withdrawal, add_money, etc.
  final DateTime? updatedAt;

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'amount': amount,
        'type': type,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
        if (userEmail != null) 'userEmail': userEmail,
        if (description != null) 'description': description,
        if (orderId != null) 'orderId': orderId,
        if (category != null) 'category': category,
      };

  // Helper to get formatted amount with sign
  String get formattedAmount {
    final sign = type == 'credit' ? '+' : '-';
    return '$sign₹${amount.toStringAsFixed(2)}';
  }

  // Helper to get icon based on category
  String get categoryIcon {
    switch (category) {
      case 'waste_bank':
        return '♻️';
      case 'eco_friendly':
        return '🌱';
      case 'withdrawal':
        return '💸';
      case 'add_money':
        return '💰';
      case 'reward':
        return '🎁';
      default:
        return '💳';
    }
  }

  // Helper to get transaction title
  String get title {
    if (description != null) return description!;
    
    switch (category) {
      case 'waste_bank':
        return 'Waste Bank Pickup Complete';
      case 'eco_friendly':
        return 'Eco-Friendly Purchase';
      case 'withdrawal':
        return 'Withdrawal to Bank';
      case 'add_money':
        return 'Money Added';
      case 'reward':
        return 'Reward Earned';
      default:
        return 'Transaction';
    }
  }
}
