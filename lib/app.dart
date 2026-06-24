import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Resolve ThemeMode from setting
    ThemeMode resolveThemeMode(String mode) {
      switch (mode) {
        case 'Clair':
          return ThemeMode.light;
        case 'Sombre':
          return ThemeMode.dark;
        case 'Système':
        default:
          return ThemeMode.system;
      }
    }

    return MaterialApp(
      title: 'Métré BTP Pro',
      debugShowCheckedModeBanner: false,
      themeMode: resolveThemeMode(appState.themeMode),
      
      // Premium Light Theme
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0F2A44),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F2A44),
          primary: const Color(0xFF0F2A44),
          secondary: const Color(0xFF1E8E5A),
          error: const Color(0xFFDC2626),
          background: const Color(0xFFF7F8FA),
          surface: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 1,
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F2A44),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        fontFamily: 'Roboto',
      ),

      // Premium Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0F2A44),
        scaffoldBackgroundColor: const Color(0xFF0A1929), // Deep dark navy
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0F2A44),
          secondary: Color(0xFF1E8E5A),
          error: Color(0xFFDC2626),
          background: Color(0xFF0A1929),
          surface: Color(0xFF0E2238), // Slightly lighter dark navy for cards
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF0E2238),
          elevation: 1,
          margin: EdgeInsets.zero,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1929),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Color(0xFF0E2238),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
