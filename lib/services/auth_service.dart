import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
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
    } catch (e) {
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
      // Fetch user profile from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        return AuthResult.error('User profile not found');
      }
      final data = doc.data();
      if (data == null) {
        return AuthResult.error('User data is null');
      }
      
      // Safely extract data with type checking
      String getName(dynamic value) {
        if (value is String) return value;
        if (value is List) return value.isNotEmpty ? value.first.toString() : '';
        return value?.toString() ?? '';
      }
      
      return AuthResult.success(User(
        id: user.uid,
        name: getName(data['name']),
        email: getName(data['email']),
        phone: getName(data['phone']),
        password: '',
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Logout current user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current logged-in user
  Future<User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return User(
      id: user.uid,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      password: '',
      createdAt: DateTime.now(),
    );
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
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return User(
        id: doc.id,
        name: data['name']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        phone: data['phone']?.toString() ?? '',
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
