import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class StaffReservationsPage extends StatefulWidget {
  const StaffReservationsPage({super.key});

  @override
  State<StaffReservationsPage> createState() => _StaffReservationsPageState();
}

class _StaffReservationsPageState extends State<StaffReservationsPage> {
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
      // Staff can see all reservations (no user_id parameter)
      final url = Uri.parse("http://localhost/swb_api/get_reservations.php");
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

  Future<void> _updateStatus(Reservation reservation, String newStatus) async {
    try {
      final url = Uri.parse("http://192.168.18.7/swb_api/update_reservation_status.php");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "reservation_id": int.parse(reservation.id),
          "status": newStatus,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        await _loadReservations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Status updated successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update status: ${data['message'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reservations (Staff)'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReservations,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reservations.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Text(
                          'No reservations yet.',
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
                              Text(
                                r.packageName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Status:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  DropdownButton<String>(
                                    value: r.status,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Pending',
                                        child: Text('Pending'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Approved',
                                        child: Text('Approved'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Completed',
                                        child: Text('Completed'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        _updateStatus(r, value);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

