import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/models.dart';

class CustomerReservationsPage extends StatefulWidget {
  const CustomerReservationsPage({super.key});

  @override
  State<CustomerReservationsPage> createState() =>
      _CustomerReservationsPageState();
}

class _CustomerReservationsPageState extends State<CustomerReservationsPage> {
  bool _isLoading = true;
  List<Reservation> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final url = Uri.parse("http://localhost/swb_api/get_reservations.php?user_id=$userId");
      final response = await http.get(url);

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        final List<dynamic> list = data['reservations'] as List<dynamic>;
        final items = list
            .map((e) => Reservation.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

        setState(() {
          _reservations = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _reservations = [];
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load reservations: ${data['message'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _reservations = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reservations: $e')),
        );
      }
    }
  }

  Future<void> _refresh() async {
    await _loadReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reservations.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No reservations yet.\nCreate one from the Party Packages page.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reservations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = _reservations[index];
                      final dateStr =
                          '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';

                      Color statusColor;
                      switch (r.status) {
                        case 'Approved':
                          statusColor = Colors.green;
                          break;
                        case 'Completed':
                          statusColor = Colors.blue;
                          break;
                        default:
                          statusColor = Colors.orange;
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      r.packageName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      r.status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month, size: 16),
                                  const SizedBox(width: 4),
                                  Text(dateStr),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.people, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${r.guests} guests'),
                                ],
                              ),
                              if (r.notes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  r.notes,
                                  style:
                                      const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: _reservations.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'To create a new reservation, go to the Party Packages page.',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New reservation'),
            ),
    );
  }
}

