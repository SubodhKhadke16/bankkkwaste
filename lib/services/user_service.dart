import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static final _firestore = FirebaseFirestore.instance;
  static final _usersCollection = _firestore.collection('users');

  /// Create a new user in Firestore
  static Future<bool> createUser({
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? profileImage,
  }) async {
    try {
      await _usersCollection.doc(userId).set({
        'name': name,
        'email': email,
        'phone': phone ?? '',
        'profileImage': profileImage ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'walletBalance': 0.0,
        'ecoPoints': 0,
      });
      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  /// Get user data
  static Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<bool> updateUser({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImage != null) updates['profileImage'] = profileImage;

      await _usersCollection.doc(userId).update(updates);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  /// Update wallet balance
  static Future<bool> updateWalletBalance(
    String userId,
    double amount, {
    bool isAdd = true,
  }) async {
    try {
      await _usersCollection.doc(userId).update({
        'walletBalance': FieldValue.increment(isAdd ? amount : -amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating wallet balance: $e');
      return false;
    }
  }

  /// Update eco points
  static Future<bool> updateEcoPoints(
    String userId,
    int points, {
    bool isAdd = true,
  }) async {
    try {
      await _usersCollection.doc(userId).update({
        'ecoPoints': FieldValue.increment(isAdd ? points : -points),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating eco points: $e');
      return false;
    }
  }

  /// Get user stream for real-time updates
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(
    String userId,
  ) => _usersCollection.doc(userId).snapshots();

  /// Save user address
  static Future<bool> saveAddress({
    required String userId,
    required String addressType,
    required Map<String, dynamic> address,
  }) async {
    try {
      await _usersCollection.doc(userId).collection('addresses').add({
        'type': addressType,
        'address': address,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error saving address: $e');
      return false;
    }
  }

  /// Get user addresses
  static Future<List<Map<String, dynamic>>> getUserAddresses(
    String userId,
  ) async {
    try {
      final snapshot =
          await _usersCollection.doc(userId).collection('addresses').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching addresses: $e');
      return [];
    }
  }
}
