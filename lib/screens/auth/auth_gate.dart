import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home_clean.dart';
import 'login_screen.dart';

/// AuthGate checks Firebase Auth state and shows appropriate screen
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

        // Show home screen if logged in, otherwise show login screen
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(
            key: ValueKey(snapshot.data!.uid),
            isLoggedIn: true,
          );
        }

        return const LoginScreen();
      },
    );
}
