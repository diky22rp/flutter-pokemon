import 'package:flutter/material.dart';
import 'package:flutter_pokemon/pages/home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFFFCC00)),
        scaffoldBackgroundColor: Color(0xFFF5F7FB),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
