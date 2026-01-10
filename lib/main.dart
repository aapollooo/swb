import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/landing_page.dart';
import 'pages/register.dart';
import 'pages/login.dart';
import 'pages/customer_dashboard.dart';
import 'pages/staff_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Returns true if a token exists
    return prefs.getString("token") != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SWB Party Needs',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black87,
          primary: Colors.black87,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),

      // 🔥 APP ENTRY LOGIC
      // Decides whether to show Landing or Dashboard on startup
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            // Check your login logic to see if you should go to 
            // Customer or Staff dashboard specifically.
            return const CustomerDashboard(); 
          }

          return const LandingPage();
        },
      ),

      // 🔁 INTEGRATED ROUTES
      // These names must match your Navigator.pushNamed() calls
      routes: {
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/customer-dashboard': (context) => const CustomerDashboard(),
        '/staff-dashboard': (context) => const StaffDashboard(),
      },
    );
  }
}