import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/user.dart';

class AuthService {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register a new user with Firebase Auth and Firestore
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return AuthResult.error('Registration failed: No user returned');
      }
      // Save user profile to Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return AuthResult.success(User(
        id: user.uid,
        name: name,
        email: email,
        phone: phone,
        password: '',
        createdAt: DateTime.now(),
      ));
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth error: $e');
      return AuthResult.error('Registration failed: ${e.message}');
    } catch (e) {
      print('Registration error: $e');
      // Even if there's an error, if it's a Pigeon type casting error but auth succeeded,
      // we should return success since the user is authenticated
      if (e.toString().contains('PigeonUserDetails') || e.toString().contains('List<Object?>')) {
        print('Pigeon type casting error ignored - registration may have succeeded');
        // Check if user is actually authenticated despite the error
        if (_auth.currentUser != null) {
          return AuthResult.success(User(
            id: _auth.currentUser!.uid,
            name: name,
            email: email,
            phone: phone,
            password: '',
            createdAt: DateTime.now(),
          ));
        }
      }
      return AuthResult.error('Registration failed: ${e.toString()}');
    }
  }

  // Login with email and password using Firebase Auth
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return AuthResult.error('Login failed: No user returned');
      }
      
      // Return user with basic info on login - DO NOT fetch from Firestore here
      // This avoids the Pigeon type casting error with cloud_firestore
      // Profile data will be fetched later when needed via getCurrentUser()
      return AuthResult.success(User(
        id: user.uid,
        name: email.split('@')[0],
        email: email,
        phone: '',
        password: '',
        createdAt: DateTime.now(),
      ));
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth error: $e');
      return AuthResult.error('Login failed: ${e.message}');
    } catch (e) {
      print('Login error: $e');
      // Even if there's an error, if it's a Pigeon type casting error but auth succeeded,
      // we should return success since the user is authenticated
      if (e.toString().contains('PigeonUserDetails') || e.toString().contains('List<Object?>')) {
        print('Pigeon type casting error ignored - auth may have succeeded');
        // Check if user is actually authenticated despite the error
        if (_auth.currentUser != null) {
          return AuthResult.success(User(
            id: _auth.currentUser!.uid,
            name: email.split('@')[0],
            email: email,
            phone: '',
            password: '',
            createdAt: DateTime.now(),
          ));
        }
      }
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Logout current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current logged-in user
  Future<User?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      try {
        // Safely extract data with type checking helper
        String safeExtractString(dynamic value) {
          if (value is String) return value;
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          return value?.toString() ?? '';
        }
        
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                throw TimeoutException('Failed to fetch user data: Operation timed out');
              },
            );
        
        if (!doc.exists) {
          return User(
            id: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            phone: '',
            password: '',
            createdAt: DateTime.now(),
          );
        }
        
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return null;
        
        return User(
          id: user.uid,
          name: safeExtractString(data['name']),
          email: safeExtractString(data['email']),
          phone: safeExtractString(data['phone']),
          password: '',
          createdAt: DateTime.now(),
        );
      } catch (e) {
        print('Firestore fetch error in getCurrentUser: $e');
        // Return user with auth data if Firestore fails
        return User(
          id: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          phone: '',
          password: '',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error fetching current user: $e');
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
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

  // Reset password using Firebase Auth
  Future<AuthResult> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Return success with a dummy user since this is just sending an email
      return AuthResult.success(User(
        id: '',
        name: '',
        email: email,
        phone: '',
        password: '',
        createdAt: DateTime.now(),
      ));
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

  factory AuthResult.success(User? user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
  final bool isSuccess;
  final String? errorMessage;
  final User? user;
}
