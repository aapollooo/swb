import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'staff_packages.dart';
import 'staff_reservations.dart';
import 'staff_inventory.dart';
import 'staff_tasks.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  String name = "";
  String role = "staff";

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString("role");

    if (savedRole != "staff") {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
      return;
    }

    setState(() {
      name = prefs.getString("name") ?? "Staff";
      role = savedRole ?? "staff";
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  Widget _dashboardCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: Colors.blueGrey.shade700),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
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
        title: const Text("Staff Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome, $name 👋",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Current role: $role",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _dashboardCard(
                    "Reservations",
                    Icons.event_note,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StaffReservationsPage(),
                        ),
                      );
                    },
                  ),
                  _dashboardCard(
                    "Inventory",
                    Icons.inventory,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StaffInventoryPage(),
                        ),
                      );
                    },
                  ),
                  _dashboardCard(
                    "My Tasks",
                    Icons.assignment,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StaffTasksPage(),
                        ),
                      );
                    },
                  ),
                  _dashboardCard(
                    "Packages",
                    Icons.inventory_2,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StaffPackagesPage(),
                        ),
                      );
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
