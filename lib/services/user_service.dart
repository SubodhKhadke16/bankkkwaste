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
      print('📝 Creating Firestore user document for: $userId');
      print('   Name: $name');
      print('   Email: $email');
      print('   Phone: ${phone ?? "(none)"}');
      
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
      
      // Verify the document was created
      final doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        print('✅ User document created and verified in Firestore');
        print('   Document ID: ${doc.id}');
        print('   Data: ${doc.data()}');
        return true;
      } else {
        print('❌ User document not found after creation');
        return false;
      }
    } catch (e) {
      print('❌ Error creating user document: $e');
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
      print('👤 Updating user profile for: $userId');
      
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) {
        updates['name'] = name;
        print('   Name: $name');
      }
      if (phone != null) {
        updates['phone'] = phone;
        print('   Phone: $phone');
      }
      if (profileImage != null) {
        updates['profileImage'] = profileImage;
        print('   Profile Image: Updated');
      }

      await _usersCollection.doc(userId).update(updates);
      print('✅ User profile updated successfully');
      
      return true;
    } catch (e) {
      print('❌ Error updating user: $e');
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
      print('💰 Updating wallet for user: $userId');
      print('   Amount: ${isAdd ? "+" : "-"}₹$amount');
      
      // First, check if user document exists
      final userDoc = await _usersCollection.doc(userId).get();
      
      if (!userDoc.exists) {
        print('⚠️ User document does not exist, creating it...');
        // Create user document with initial wallet balance
        await _usersCollection.doc(userId).set({
          'walletBalance': isAdd ? amount : -amount,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'ecoPoints': 0,
        });
        print('✅ User document created with wallet balance: ₹${isAdd ? amount : -amount}');
        return true;
      }
      
      // User exists, check if walletBalance field exists
      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('walletBalance')) {
        print('⚠️ walletBalance field missing, initializing...');
        // Set initial balance
        await _usersCollection.doc(userId).update({
          'walletBalance': isAdd ? amount : -amount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ walletBalance initialized to: ₹${isAdd ? amount : -amount}');
        return true;
      }
      
      // Normal update with increment
      await _usersCollection.doc(userId).update({
        'walletBalance': FieldValue.increment(isAdd ? amount : -amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Verify the update
      final updatedDoc = await _usersCollection.doc(userId).get();
      final newBalance = (updatedDoc.data()?['walletBalance'] ?? 0.0);
      print('✅ Wallet updated successfully. New balance: ₹$newBalance');
      
      return true;
    } catch (e) {
      print('❌ Error updating wallet balance for user $userId: $e');
      return false;
    }
  }

  /// Set wallet balance to a specific value (for corrections)
  static Future<bool> setWalletBalance(
    String userId,
    double balance,
  ) async {
    try {
      await _usersCollection.doc(userId).update({
        'walletBalance': balance,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error setting wallet balance: $e');
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
      print('🌱 Updating eco points for user: $userId');
      print('   Points: ${isAdd ? "+" : "-"}$points');
      
      await _usersCollection.doc(userId).update({
        'ecoPoints': FieldValue.increment(isAdd ? points : -points),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Verify the update
      final updatedDoc = await _usersCollection.doc(userId).get();
      final newPoints = (updatedDoc.data()?['ecoPoints'] ?? 0);
      print('✅ Eco points updated successfully. New points: $newPoints');
      
      return true;
    } catch (e) {
      print('❌ Error updating eco points for user $userId: $e');
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

  /// Check if user profile exists and is complete
  static Future<bool> userProfileExists(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();
      
      if (!doc.exists || doc.data() == null) return false;
      
      final data = doc.data()!;
      final hasName = data.containsKey('name') && 
                      data['name'].toString().trim().isNotEmpty;
      final hasPhone = data.containsKey('phone') && 
                       data['phone'].toString().trim().isNotEmpty;
      
      return hasName && hasPhone;
    } catch (e) {
      print('Error checking user profile: $e');
      return false;
    }
  }
}
