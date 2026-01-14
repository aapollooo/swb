class PartyPackage {
  final String id;
  final String name;
  final String description;
  final double price;
  final int capacity;

  const PartyPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.capacity,
  });
}

/// Shared list of available party packages.
///
/// Both customer and staff UIs should use this so they always
/// see the same data.
const List<PartyPackage> partyPackages = <PartyPackage>[
  PartyPackage(
    id: 'pkg_basic',
    name: 'Basic Party Package',
    description: 'Tables, chairs, and basic decorations for small gatherings.',
    price: 2500,
    capacity: 30,
  ),
  PartyPackage(
    id: 'pkg_premium',
    name: 'Premium Party Package',
    description:
        'Themed setup with sound system, lighting, and photo backdrop included.',
    price: 5200,
    capacity: 60,
  ),
  PartyPackage(
    id: 'pkg_kids',
    name: 'Kids Party Package',
    description:
        'Colorful setup with balloons, kiddie tables, and simple game props.',
    price: 3000,
    capacity: 40,
  ),
];

class Reservation {
  final String id;
  final String packageId;
  final String packageName;
  final DateTime date;
  final int guests;
  final String notes;
  final String status; // e.g. Pending, Approved, Completed

  const Reservation({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.date,
    required this.guests,
    required this.notes,
    required this.status,
  });

  Reservation copyWith({
    String? id,
    String? packageId,
    String? packageName,
    DateTime? date,
    int? guests,
    String? notes,
    String? status,
  }) {
    return Reservation(
      id: id ?? this.id,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      date: date ?? this.date,
      guests: guests ?? this.guests,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageId': packageId,
      'packageName': packageName,
      'date': date.toIso8601String(),
      'guests': guests,
      'notes': notes,
      'status': status,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase (from old SharedPreferences) and snake_case (from API)
    String dateStr = json['date'] as String;
    DateTime date;
    if (dateStr.contains('T')) {
      date = DateTime.parse(dateStr);
    } else {
      // Parse YYYY-MM-DD format from API
      date = DateTime.parse(dateStr);
    }
    
    return Reservation(
      id: json['id'].toString(),
      packageId: json['package_id'] ?? json['packageId'] ?? '',
      packageName: json['package_name'] ?? json['packageName'] ?? '',
      date: date,
      guests: (json['guests'] as num).toInt(),
      notes: (json['notes'] ?? '') as String,
      status: (json['status'] ?? 'Pending') as String,
    );
  }
}

