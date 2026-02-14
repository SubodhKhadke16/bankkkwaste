import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home_clean.dart';

/// AuthGate checks Firebase Auth state and shows Home Screen
/// Users can browse the app without logging in
class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Always show home screen, but with appropriate login state
        final isLoggedIn = snapshot.hasData && snapshot.data != null;
        
        return HomeScreen(
          key: ValueKey(snapshot.data?.uid ?? 'guest'),
          isLoggedIn: isLoggedIn,
        );
      },
    );
}
