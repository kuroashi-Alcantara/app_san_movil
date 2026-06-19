import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const SanApp());
}

class SanApp extends StatelessWidget {
  const SanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de San',
      debugShowCheckedModeBanner: false, // Oculta la etiqueta roja de "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green), // Un verde financiero
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}