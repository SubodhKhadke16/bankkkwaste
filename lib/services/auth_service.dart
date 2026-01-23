import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _keyUserId = 'current_user_id';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Register user with Firestore (local auth - no Firebase Auth)
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Check if email already exists
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (existingUser.docs.isNotEmpty) {
        return AuthResult.error('Email already registered');
      }

      // Create new user document
      final userDoc = await _firestore.collection('users').add({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password, // In production, hash this!
        'createdAt': FieldValue.serverTimestamp(),
      });

      final user = User(
        id: userDoc.id,
        name: name,
        email: email,
        phone: phone,
        password: password,
        createdAt: DateTime.now(),
      );

      // Save login state
      await _saveLoginState(userDoc.id);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Registration failed: ${e.toString()}');
    }
  }

  // Login user with Firestore (local auth - no Firebase Auth)
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Find user by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return AuthResult.error('User not found');
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();

      // Check password
      if (data['password'] != password) {
        return AuthResult.error('Incorrect password');
      }

      final user = User(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        password: '',
        createdAt: DateTime.now(),
      );

      // Save login state
      await _saveLoginState(doc.id);

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Save login state to SharedPreferences
  Future<void> _saveLoginState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  // Get current logged-in user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyUserId);

      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return User(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        password: '',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Update user profile in Firestore
  Future<AuthResult> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update({
        'name': user.name,
        'phone': user.phone,
      });
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Update failed: ${e.toString()}');
    }
  }

  // Developer/Admin method: Get all registered users from Firestore
  Future<List<User>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    
    // Safely extract data with type checking
    String safeExtractString(dynamic value) {
      if (value is String) return value;
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      return value?.toString() ?? '';
    }
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return User(
        id: doc.id,
        name: safeExtractString(data['name']),
        email: safeExtractString(data['email']),
        phone: safeExtractString(data['phone']),
        password: '',
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  // Developer/Admin method: Delete a user from Firestore
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Developer/Admin method: Clear all users from Firestore (use with caution!)
  Future<void> clearAllData() async {
    final batch = _firestore.batch();
    final snapshot = await _firestore.collection('users').get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Reset password
  Future<AuthResult> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      // Find user by email
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return AuthResult.error('User not found');
      }

      // Update password
      await querySnapshot.docs.first.reference.update({
        'password': newPassword, // In production, hash this!
      });

      return AuthResult.success(null);
    } catch (e) {
      return AuthResult.error('Password reset failed: ${e.toString()}');
    }
  }
}

// Result class for authentication operations
class AuthResult {

  AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.success(User? user) => AuthResult._(
      isSuccess: true,
      user: user,
    );

  factory AuthResult.error(String message) => AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  final bool isSuccess;
  final String? errorMessage;
  final User? user;
}
