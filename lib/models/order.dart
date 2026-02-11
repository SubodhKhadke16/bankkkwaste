import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_item.dart';

class Order {
  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.deliveryAddress,
    this.phoneNumber,
    this.userName,
    this.userEmail,
    this.updatedAt,
    this.pickupDate,
    this.pickupTimeSlot,
    this.isWasteBankOrder = false,
  });

  factory Order.fromFirestore(String id, Map<String, dynamic> data) {
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final items = itemsData
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Order(
      id: id,
      userId: data['userId'] ?? '',
      items: items,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryAddress: data['deliveryAddress'],
      phoneNumber: data['phoneNumber'],
      userName: data['userName'],
      userEmail: data['userEmail'],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      pickupDate: (data['pickupDate'] as Timestamp?)?.toDate(),
      pickupTimeSlot: data['pickupTimeSlot'],
      isWasteBankOrder: data['isWasteBankOrder'] ?? false,
    );
  }

  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String status; // pending, confirmed, processing, delivered, cancelled
  final DateTime createdAt;
  final String? deliveryAddress;
  final String? phoneNumber;
  final String? userName;
  final String? userEmail;
  final DateTime? updatedAt;
  final DateTime? pickupDate;
  final String? pickupTimeSlot;
  final bool isWasteBankOrder;

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
        if (deliveryAddress != null) 'deliveryAddress': deliveryAddress,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (userName != null) 'userName': userName,
        if (userEmail != null) 'userEmail': userEmail,
        if (pickupDate != null) 'pickupDate': Timestamp.fromDate(pickupDate!),
        if (pickupTimeSlot != null) 'pickupTimeSlot': pickupTimeSlot,
        'isWasteBankOrder': isWasteBankOrder,
      };

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}
