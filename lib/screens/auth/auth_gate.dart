import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../home_clean.dart';
import 'login_screen.dart';

/// AuthGate checks login state and shows appropriate screen
class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final loggedIn = await _authService.isLoggedIn();
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show home screen if logged in, otherwise show login screen
    return _isLoggedIn
        ? HomeScreen(
            key: ValueKey(_isLoggedIn),
            isLoggedIn: true,
          )
        : const LoginScreen();
  }
}
