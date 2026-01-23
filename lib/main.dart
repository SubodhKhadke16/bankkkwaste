import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'screens/auth/auth_gate.dart';
import 'services/cart_service.dart';
import 'services/product_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize products - add sample products if none exist
  await ProductService.initializeProducts();

  runApp(const WastecBankApp());
}

class WastecBankApp extends StatelessWidget {
  const WastecBankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => CartService(),
        child: MaterialApp(
          title: 'Wastec Bank',
          theme: WastecTheme.lightTheme,
          home: const AuthGate(),
          debugShowCheckedModeBanner: false,
        ),
      );
}
