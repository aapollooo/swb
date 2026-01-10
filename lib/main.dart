import 'package:flutter/material.dart';

import 'pages/landing_page.dart';
import 'pages/register.dart';
import 'pages/login.dart';
import 'pages/dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
      useMaterial3: true,
      // Sets the color scheme for the whole app (buttons, icons, etc.)
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black87,
        primary: Colors.black87, // Primary color for buttons/links
      ),
      // Sets the default font color for all Text widgets
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: Colors.black87), // Standard text
        bodyMedium: TextStyle(color: Colors.black54), // Subtitles/secondary text
      ),
    ),
      title: 'SWB Party Needs',
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/register': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
    );
  }
}
