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

  /// Returns the role of the currently logged-in user.
  ///
  /// - `null`  → no token saved, user should see the Landing page.
  /// - `'staff'` or `'customer'` → route to the appropriate dashboard.
  Future<String?> _getLoggedInRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null) return null;

    // Default any logged-in user with no explicit role to "customer".
    return prefs.getString("role") ?? 'customer';
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
      // Decides whether to show Landing, Customer, or Staff dashboard on startup
      home: FutureBuilder<String?>(
        future: _getLoggedInRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final role = snapshot.data;

          if (role == 'staff') {
            return const StaffDashboard();
          } else if (role == 'customer') {
            return const CustomerDashboard();
          } else {
            // No token saved → show marketing / auth entry point
            return const LandingPage();
          }
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