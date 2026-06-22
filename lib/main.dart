import 'package:flutter/material.dart';
//import 'screens/login_screen.dart';
import 'screens/check_auth_screen.dart';

void main() {
  runApp(const SanApp());
}

class SanApp extends StatelessWidget {
  const SanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Api-san Movil',
      // Cambiamos el home para que el semáforo sea lo primero que se ejecute
      home: const CheckAuthScreen(),
    );
  }
}