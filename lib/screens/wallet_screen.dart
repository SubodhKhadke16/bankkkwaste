import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../widgets/profile_wallet_actions.dart';
import '../widgets/wallet_tab.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: WastecColors.primaryGreen,
          title: const Text(
            'Wallet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: const [ProfileWalletActions()],
        ),
        body: const WalletTab(),
      );
}
