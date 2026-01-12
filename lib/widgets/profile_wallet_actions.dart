import 'package:flutter/material.dart';

import '../screens/profile_screen.dart';
import '../screens/auth/login_screen.dart';

class ProfileWalletActions extends StatelessWidget {
  const ProfileWalletActions({super.key, this.iconColor = Colors.white, this.isLoggedIn = false});

  final Color iconColor;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  isLoggedIn ? Icons.person_outline : Icons.login,
                  color: iconColor,
                  size: 24,
                ),
                onPressed: () {
                  if (isLoggedIn) {
                    // Navigate to profile screen
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  } else {
                    // Navigate to login screen
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
}
