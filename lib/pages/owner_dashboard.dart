import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  String name = "";
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    checkSession();
    _loadDashboardStats();
  }

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString("role");

    if (savedRole != "owner" && savedRole != "admin") {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
      return;
    }

    setState(() {
      name = prefs.getString("name") ?? "Owner";
    });
  }

  Future<void> _loadDashboardStats() async {
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse("http://192.168.18.7/swb_api/get_dashboard_stats.php");
      final response = await http.get(url);

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          _stats = data['stats'] as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stats: $e')),
        );
      }
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/login");
  }

  Widget _statCard(String title, dynamic value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                if (value is double)
                  Text(
                    '₱${value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  )
                else
                  Text(
                    value.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardStats,
              child: SingleChildScrollView(
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
                    const Text(
                      "Current role: Owner",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Financial Overview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _statCard(
                          "Total Revenue",
                          _stats['total_revenue'] ?? 0.0,
                          Icons.trending_up,
                          Colors.green,
                        ),
                        _statCard(
                          "Total Expenses",
                          _stats['total_expenses'] ?? 0.0,
                          Icons.trending_down,
                          Colors.red,
                        ),
                        _statCard(
                          "Profit",
                          _stats['profit'] ?? 0.0,
                          Icons.account_balance,
                          _stats['profit'] != null &&
                                  (_stats['profit'] as num) >= 0
                              ? Colors.blue
                              : Colors.orange,
                        ),
                        _statCard(
                          "Reservations",
                          _stats['total_reservations'] ?? 0,
                          Icons.event,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "System Status",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _statCard(
                          "Pending Reservations",
                          _stats['pending_reservations'] ?? 0,
                          Icons.pending,
                          Colors.orange,
                        ),
                        _statCard(
                          "Low Stock Items",
                          _stats['low_stock_items'] ?? 0,
                          Icons.warning,
                          Colors.red,
                        ),
                        _statCard(
                          "Pending Tasks",
                          _stats['pending_tasks'] ?? 0,
                          Icons.assignment,
                          Colors.blue,
                        ),
                        _statCard(
                          "Pending Expenses",
                          _stats['pending_expenses'] ?? 0,
                          Icons.receipt,
                          Colors.amber,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Quick Actions",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              leading: const Icon(Icons.approval),
                              title: const Text("Approve Reservations"),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Approval page coming soon',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.receipt_long),
                              title: const Text("Approve Expenses"),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Expense approval page coming soon',
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.bar_chart),
                              title: const Text("View Reports"),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Reports page coming soon',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
