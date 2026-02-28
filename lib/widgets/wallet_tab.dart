import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../screens/otp_login_screen.dart';
import '../screens/debug_transactions_screen.dart';
import '../screens/transaction_history_screen.dart';
import '../services/auth_service.dart';
import '../services/connectivity_service.dart';
import '../services/transaction_service.dart';
import '../services/user_service.dart';
import '../widgets/offline_screen.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  Future<void> _checkAndRefresh() async {
    final isConnected = await _connectivityService.checkConnection();
    if (isConnected) {
      setState(() {
        // Trigger rebuild with connection
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectionStatus,
      initialData: _connectivityService.isConnected,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;
        
        if (!isConnected) {
          return OfflineScreen(onRetry: _checkAndRefresh);
        }
        
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _WalletBalanceCard(),
                const SizedBox(height: 20),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const _WalletQuickActions(),
                const SizedBox(height: 24),
                Text(
                  'Wallet Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const _WalletServicesList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WalletQuickActions extends StatelessWidget {
  const _WalletQuickActions();

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _WalletQuickAction(
            icon: Icons.add_circle_outline,
            label: 'Add Money',
            onTap: () => _showComingSoonDialog(context, 'Add Money'),
          ),
          _WalletQuickAction(
            icon: Icons.arrow_circle_up_outlined,
            label: 'Send Money',
            onTap: () => _showComingSoonDialog(context, 'Send Money'),
          ),
          _WalletQuickAction(
            icon: Icons.arrow_circle_down_outlined,
            label: 'Withdraw',
            onTap: () => _showComingSoonDialog(context, 'Withdraw'),
          ),
          _WalletQuickAction(
            icon: Icons.card_giftcard,
            label: 'Rewards',
            onTap: () => _showComingSoonDialog(context, 'Rewards'),
          ),
        ],
      );

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Feature'),
        content: Text(
          'The $feature feature is coming soon! You can currently view your balance and transaction history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _WalletServicesList extends StatelessWidget {
  const _WalletServicesList();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WalletServiceTile(
            icon: Icons.receipt_long,
            title: 'Transaction History',
            subtitle: 'Track every credit and debit instantly.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TransactionHistoryScreen(),
              ),
            ),
          ),
          const _WalletServiceTile(
            icon: Icons.account_balance,
            title: 'Linked Accounts',
            subtitle: 'Manage bank accounts and UPI IDs.',
          ),
          const _WalletServiceTile(
            icon: Icons.security,
            title: 'Wallet Security',
            subtitle: 'Set PIN, biometric login, and alerts.',
          ),
          const _WalletServiceTile(
            icon: Icons.support_agent,
            title: 'Help & Support',
            subtitle: 'Get assistance with wallet services.',
          ),
          _WalletServiceTile(
            icon: Icons.bug_report,
            title: 'Debug Transactions',
            subtitle: 'View all transaction details and Firebase IDs',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DebugTransactionsScreen(),
              ),
            ),
          ),
        ],
      );
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard();

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userId = authService.currentUserId;

    if (userId == null) {
      return const _LoginPromptCard();
    }

    return StreamBuilder(
      stream: UserService.getUserStream(userId),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const _LoadingBalanceCard();
        }

        final userData = userSnapshot.data!.data();
        final balance = (userData?['walletBalance'] ?? 0.0).toDouble();

        return FutureBuilder<Map<String, dynamic>>(
          future: TransactionService.getTransactionStats(userId),
          builder: (context, statsSnapshot) {
            final monthlyEarnings =
                statsSnapshot.data?['monthlyEarnings'] ?? 0.0;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    WastecColors.primaryGreen,
                    WastecColors.primaryGreen.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: WastecColors.primaryGreen.withOpacity(0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waste Wallet Balance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${monthlyEarnings.toStringAsFixed(0)} earned this month',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _LoginPromptCard extends StatelessWidget {
  const _LoginPromptCard();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              WastecColors.primaryGreen,
              WastecColors.primaryGreen.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WastecColors.primaryGreen.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Login to Access Your Wallet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'View your balance, transactions, and manage your earnings',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OtpLoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: WastecColors.primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Login Now',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
}

class _LoadingBalanceCard extends StatelessWidget {
  const _LoadingBalanceCard();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              WastecColors.primaryGreen,
              WastecColors.primaryGreen.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WastecColors.primaryGreen.withOpacity(0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Waste Wallet Balance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      );
}

class _WalletQuickAction extends StatelessWidget {
  const _WalletQuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: WastecColors.lightGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: WastecColors.primaryGreen),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: WastecColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      );
}

class _WalletServiceTile extends StatelessWidget {
  const _WalletServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: WastecColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: WastecColors.primaryGreen),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[400]
                  : WastecColors.mediumGray,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: WastecColors.mediumGray,
          ),
        ),
      );
}
