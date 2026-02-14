import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/theme.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../services/user_service.dart';

/// Debug screen to view all transactions with their Firebase IDs
class DebugTransactionsScreen extends StatefulWidget {
  const DebugTransactionsScreen({super.key});

  @override
  State<DebugTransactionsScreen> createState() =>
      _DebugTransactionsScreenState();
}

class _DebugTransactionsScreenState extends State<DebugTransactionsScreen> {
  bool _isResetting = false;

  Future<void> _resetWalletBalance() async {
    final userId = AuthService().currentUserId;
    if (userId == null) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Wallet Balance'),
        content: const Text(
          'This will set your wallet balance to ₹420. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Reset to ₹420'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isResetting = true);

    try {
      // Manually set wallet balance to 420
      await UserService.setWalletBalance(userId, 420.0);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Wallet balance reset to ₹420'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {}); // Refresh UI
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isResetting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUserId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Debug Transactions')),
        body: const Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Transactions'),
        backgroundColor: WastecColors.primaryGreen,
      ),
      body: FutureBuilder<List<WalletTransaction>>(
        future: TransactionService.getUserTransactions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No transactions found'),
            );
          }

          final transactions = snapshot.data!;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Column(
                  children: [
                    Text(
                      'Total Transactions: ${transactions.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'User ID: $userId',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isResetting ? null : _resetWalletBalance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      icon: _isResetting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh, color: Colors.white),
                      label: Text(
                        _isResetting ? 'Resetting...' : 'Reset Balance to ₹420',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          tx.type == 'credit'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: tx.type == 'credit'
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(
                          '₹${tx.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tx.type == 'credit'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.description ?? 'No description'),
                            Text('Order ID: ${tx.orderId ?? "N/A"}'),
                            Text('Firebase ID: ${tx.id}'),
                            Text('Created: ${tx.createdAt}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: tx.id),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied Firebase ID: ${tx.id}'),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
