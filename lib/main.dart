import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/cart_screen.dart';
import 'services/cart_service.dart';
import 'services/product_service.dart';
import 'widgets/network_status_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize products - add sample products if none exist
  await ProductService.initializeProducts();

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  runApp(WastecBankApp(themeProvider: themeProvider));
}

class WastecBankApp extends StatelessWidget {

  const WastecBankApp({required this.themeProvider, Key? key}) : super(key: key);
  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, provider, _) => StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // Get current user ID (null if not logged in)
              final userId = snapshot.data?.uid;

              return ChangeNotifierProvider(
                // Use key to force recreation of CartService when user changes
                key: ValueKey(userId),
                create: (_) => CartService(userId: userId),
                child: MaterialApp(
                  title: 'Wastec Bank',
                  theme: WastecTheme.lightTheme,
                  darkTheme: WastecTheme.darkTheme,
                  themeMode: provider.themeMode,
                  home: const NetworkStatusBanner(child: AuthGate()),
                  debugShowCheckedModeBanner: false,
                  routes: {
                    '/cart': (context) => const CartScreen(),
                  },
                ),
              );
            },
          ),
      ),
    );
}
