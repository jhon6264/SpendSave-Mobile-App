import 'package:flutter/material.dart';
import 'package:spend_save/services/hive_service.dart';
import 'package:spend_save/screens/main_screen.dart'; // ← CHANGE THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await HiveService.init();
    print('✅ Hive initialized successfully');
  } catch (e) {
    print('❌ Hive initialization failed: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendSave',
      theme: ThemeData(
        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6A11CB),
          secondary: Color(0xFF2575FC),
          background: Color(0xFF0F2027),
          surface: Color(0xFF203A43),
        ),
        
        // Typography
        fontFamily: 'Inter',
        
        // Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 48,
            fontWeight: FontWeight.w700,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
          ),
        ),
        
        // Bottom Navigation Theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
        ),
      ),
      home: const MainScreen(), // ← CHANGE TO MainScreen
      debugShowCheckedModeBanner: false,
    );
  }
}