import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String fullName = "";

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final name = prefs.getString("name");

    if (token == null) {
      // Not logged in → back to login
      Navigator.pushReplacementNamed(context, "/login");
    } else {
      setState(() {
        fullName = name ?? "User";
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacementNamed(context, "/login");
  }

  Widget dashboardCard(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $fullName 👋",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  dashboardCard(
                    "Products",
                    Icons.inventory,
                    () {
                      // Navigator.pushNamed(context, "/products");
                    },
                  ),
                  dashboardCard(
                    "Orders",
                    Icons.shopping_cart,
                    () {
                      // Navigator.pushNamed(context, "/orders");
                    },
                  ),
                  dashboardCard(
                    "Customers",
                    Icons.people,
                    () {
                      // Navigator.pushNamed(context, "/customers");
                    },
                  ),
                  dashboardCard(
                    "Reports",
                    Icons.bar_chart,
                    () {
                      // Navigator.pushNamed(context, "/reports");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
