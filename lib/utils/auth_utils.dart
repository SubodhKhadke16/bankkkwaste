import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../screens/otp_login_screen.dart';

/// Utility class for authentication-related helpers
class AuthUtils {
  /// Check if user is logged in
  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Get current user ID
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// Show login required dialog
  static void showLoginDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(
              Icons.lock_outline,
              color: WastecColors.primaryGreen,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Login Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message ?? 'Please login to add items to cart and place orders.',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              
              // Navigate directly to OTP login
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OtpLoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WastecColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Execute action if logged in, otherwise show login dialog
  static void requireLogin(
    BuildContext context,
    VoidCallback action, {
    String? message,
  }) {
    if (isLoggedIn()) {
      action();
    } else {
      showLoginDialog(context, message: message);
    }
  }
}
