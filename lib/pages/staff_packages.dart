import 'package:flutter/material.dart';

import '../models/models.dart';

class StaffPackagesPage extends StatelessWidget {
  const StaffPackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Packages'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: partyPackages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final pkg = partyPackages[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: ListTile(
              title: Text(
                pkg.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(pkg.description),
                  const SizedBox(height: 4),
                  Text('Capacity: ${pkg.capacity} pax'),
                  Text('Price: ₱${pkg.price.toStringAsFixed(0)}'),
                ],
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.edit),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Editing packages is not yet implemented. This list is shared with customers.',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

