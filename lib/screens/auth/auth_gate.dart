import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../services/auth_service.dart';
import '../home_clean.dart';

/// AuthGate shows home screen (guest or logged-in)
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  late final fb_auth.FirebaseAuth _firebaseAuth;

  @override
  void initState() {
    super.initState();
    _firebaseAuth = fb_auth.FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb_auth.User?>(
      stream: _firebaseAuth.authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for Firebase to initialize, show loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Always show home screen (whether user is logged in or guest)
        // isLoggedIn parameter tells HomeScreen if user is authenticated
        final isLoggedIn = snapshot.hasData && snapshot.data != null;
        return HomeScreen(
          key: ValueKey(isLoggedIn), // Force rebuild when auth state changes
          isLoggedIn: isLoggedIn,
        );
      },
    );
  }
}
