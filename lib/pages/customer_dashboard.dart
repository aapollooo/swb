import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  String name = "";

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString("role");

    if (role == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    } 
    // Optional: Ensure a Staff member can't access the Customer dashboard
    else if (role != "customer") {
      if (mounted) {
         Navigator.pushReplacementNamed(context, "/login");
      }
    }

    setState(() {
      name = prefs.getString("name") ?? "Customer";
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, $name 👋",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text("Browse Packages"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text("My Reservations"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Payments"),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
