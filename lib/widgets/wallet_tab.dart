import 'package:flutter/material.dart';

import '../config/theme.dart';

class WalletTab extends StatelessWidget {
  const WalletTab({super.key});

  @override
  Widget build(BuildContext context) => const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WalletBalanceCard(),
              SizedBox(height: 20),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              _WalletQuickActions(),
              SizedBox(height: 24),
              Text(
                'Wallet Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              _WalletServicesList(),
            ],
          ),
        ),
      );
}

class _WalletQuickActions extends StatelessWidget {
  const _WalletQuickActions();

  @override
  Widget build(BuildContext context) => const Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _WalletQuickAction(
            icon: Icons.add_circle_outline,
            label: 'Add Money',
          ),
          _WalletQuickAction(
            icon: Icons.arrow_circle_up_outlined,
            label: 'Send Money',
          ),
          _WalletQuickAction(
            icon: Icons.arrow_circle_down_outlined,
            label: 'Withdraw',
          ),
          _WalletQuickAction(
            icon: Icons.card_giftcard,
            label: 'Rewards',
          ),
        ],
      );
}

class _WalletServicesList extends StatelessWidget {
  const _WalletServicesList();

  @override
  Widget build(BuildContext context) => const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WalletServiceTile(
            icon: Icons.receipt_long,
            title: 'Transaction History',
            subtitle: 'Track every credit and debit instantly.',
          ),
          _WalletServiceTile(
            icon: Icons.account_balance,
            title: 'Linked Accounts',
            subtitle: 'Manage bank accounts and UPI IDs.',
          ),
          _WalletServiceTile(
            icon: Icons.security,
            title: 'Wallet Security',
            subtitle: 'Set PIN, biometric login, and alerts.',
          ),
          _WalletServiceTile(
            icon: Icons.support_agent,
            title: 'Help & Support',
            subtitle: 'Get assistance with wallet services.',
          ),
        ],
      );
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard();

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
            const Text(
              '₹7,450.00',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.white.withOpacity(0.9)),
                const SizedBox(width: 8),
                Text(
                  '₹1,200 earned this month',
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
}

class _WalletQuickAction extends StatelessWidget {
  const _WalletQuickAction({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
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
      );
}

class _WalletServiceTile extends StatelessWidget {
  const _WalletServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
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
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: WastecColors.mediumGray,
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
