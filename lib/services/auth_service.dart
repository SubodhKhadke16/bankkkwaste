import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../models/user.dart' as models;
import 'user_service.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final firestore.FirebaseFirestore _firestore =
      firestore.FirebaseFirestore.instance;

  // Get current Firebase Auth user
  auth.User? get currentUser => _auth.currentUser;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Stream of auth state changes
  Stream<auth.User?> get authStateChanges => _auth.authStateChanges();

  // Register user with Firebase Auth and create Firestore profile
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.error('Registration failed');
      }

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Create user profile in Firestore
      await UserService.createUser(
        userId: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
      );

      final user = models.User(
        id: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        password: '',
        createdAt: DateTime.now(),
      );

      return AuthResult.success(user);
    } on auth.FirebaseAuthException catch (e) {
      var message = 'Registration failed';
      if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email already registered';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }
      return AuthResult.error(message);
    } catch (e) {
      return AuthResult.error('Registration failed: ${e.toString()}');
    }
  }

  // Login user with Firebase Auth
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return AuthResult.error('Login failed');
      }

      // Get user profile from Firestore
      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        return AuthResult.error('User profile not found');
      }

      final data = doc.data()!;
      final user = models.User(
        id: credential.user!.uid,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        password: '',
        createdAt: DateTime.now(),
      );

      return AuthResult.success(user);
    } on auth.FirebaseAuthException catch (e) {
      var message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'User not found';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled';
      }
      return AuthResult.error(message);
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current logged-in user from Firestore
  Future<models.User?> getCurrentUser() async {
    try {
      final authUser = _auth.currentUser;
      if (authUser == null) return null;

      final doc = await _firestore.collection('users').doc(authUser.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      return models.User(
        id: authUser.uid,
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
  bool isLoggedIn() => _auth.currentUser != null;

  // Update user profile in Firestore
  Future<AuthResult> updateUser(models.User user) async {
    try {
      // Update Firestore user document
      await _firestore.collection('users').doc(user.id).update({
        'name': user.name,
        'phone': user.phone,
      });

      // Try to update display name in Firebase Auth, but ignore if it fails
      try {
        await _auth.currentUser?.updateDisplayName(user.name);
      } catch (e) {
        // Ignore Firebase Auth display name update errors
        // The Firestore data is what matters most
        print('Display name update skipped: $e');
      }

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Update failed: ${e.toString()}');
    }
  }

  // Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null);
    } on auth.FirebaseAuthException catch (e) {
      var message = 'Password reset failed';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }
      return AuthResult.error(message);
    } catch (e) {
      return AuthResult.error('Password reset failed: ${e.toString()}');
    }
  }

  // Developer/Admin method: Get all registered users from Firestore
  Future<List<models.User>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return models.User(
        id: doc.id,
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        phone: data['phone'] ?? '',
        password: '',
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  // Developer/Admin method: Delete a user (requires admin SDK)
  Future<bool> deleteUser(String userId) async {
    try {
      // Note: Deleting Firebase Auth users requires Admin SDK
      // This only deletes the Firestore profile
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      return false;
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

  factory AuthResult.success(models.User? user) => AuthResult._(
        isSuccess: true,
        user: user,
      );

  factory AuthResult.error(String message) => AuthResult._(
        isSuccess: false,
        errorMessage: message,
      );
  final bool isSuccess;
  final String? errorMessage;
  final models.User? user;
}
