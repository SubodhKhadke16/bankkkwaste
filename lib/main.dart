
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/theme.dart';
import 'screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WastecBankApp());
}

class WastecBankApp extends StatelessWidget {
  const WastecBankApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Wastec Bank',
      theme: WastecTheme.lightTheme,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
}
