import 'package:flutter/material.dart';
import '../utils/seed_eco_products.dart';

/// Simple admin page to seed eco products to Firebase.
/// Add this as a route or run once during development.
class AdminSeedPage extends StatefulWidget {
  const AdminSeedPage({super.key});

  @override
  State<AdminSeedPage> createState() => _AdminSeedPageState();
}

class _AdminSeedPageState extends State<AdminSeedPage> {
  String _status = 'Ready to seed products';
  bool _isLoading = false;

  Future<void> _seedProducts() async {
    setState(() {
      _isLoading = true;
      _status = 'Seeding products...';
    });

    try {
      await SeedEcoProducts.seedProducts();
      setState(() {
        _status = '✅ Successfully seeded products!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Seed Products'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _seedProducts,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload),
                label: Text(_isLoading ? 'Seeding...' : 'Seed Eco Products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Note: This will add sample eco products to your Firestore database.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
