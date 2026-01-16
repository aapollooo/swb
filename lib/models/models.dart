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

// ============================================
// EXPANDED RESERVATION MODEL
// ============================================
class Reservation {
  final String id;
  final int userId;
  final String packageId;
  final String packageName;
  
  // Client Information
  final String clientName;
  final String? clientPhone;
  final String? clientEmail;
  final String? clientAddress;
  final String? venueLocation;
  final String preferredContact;
  
  // Event Details
  final String? eventType;
  final DateTime eventDate;
  final String? eventStartTime;
  final String? eventEndTime;
  final int numberOfGuests;
  final String? eventTheme;
  final String? venueType;
  
  // Services Required
  final bool needsDecoration;
  final bool needsEquipment;
  final bool needsEntertainment;
  final bool needsPhotography;
  final bool needsCleanup;
  final String? servicesNotes;
  
  // Budget & Payment
  final double? estimatedBudget;
  final double depositAmount;
  final double? totalAmount;
  final String? paymentMethod;
  final String paymentStatus;
  final String? paymentSchedule;
  
  // Additional Notes
  final String? specialRequests;
  final String? accessibilityRequirements;
  final String? contactPerson;
  
  // System Fields
  final String status;
  final int? approvedBy;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Reservation({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.packageName,
    required this.clientName,
    this.clientPhone,
    this.clientEmail,
    this.clientAddress,
    this.venueLocation,
    this.preferredContact = 'phone',
    this.eventType,
    required this.eventDate,
    this.eventStartTime,
    this.eventEndTime,
    required this.numberOfGuests,
    this.eventTheme,
    this.venueType,
    this.needsDecoration = false,
    this.needsEquipment = false,
    this.needsEntertainment = false,
    this.needsPhotography = false,
    this.needsCleanup = false,
    this.servicesNotes,
    this.estimatedBudget,
    this.depositAmount = 0.0,
    this.totalAmount,
    this.paymentMethod,
    this.paymentStatus = 'Pending',
    this.paymentSchedule,
    this.specialRequests,
    this.accessibilityRequirements,
    this.contactPerson,
    this.status = 'Pending',
    this.approvedBy,
    this.approvedAt,
    required this.createdAt,
    this.updatedAt,
  });

  Reservation copyWith({
    String? id,
    int? userId,
    String? packageId,
    String? packageName,
    String? clientName,
    String? clientPhone,
    String? clientEmail,
    String? clientAddress,
    String? venueLocation,
    String? preferredContact,
    String? eventType,
    DateTime? eventDate,
    String? eventStartTime,
    String? eventEndTime,
    int? numberOfGuests,
    String? eventTheme,
    String? venueType,
    bool? needsDecoration,
    bool? needsEquipment,
    bool? needsEntertainment,
    bool? needsPhotography,
    bool? needsCleanup,
    String? servicesNotes,
    double? estimatedBudget,
    double? depositAmount,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? paymentSchedule,
    String? specialRequests,
    String? accessibilityRequirements,
    String? contactPerson,
    String? status,
    int? approvedBy,
    DateTime? approvedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      packageId: packageId ?? this.packageId,
      packageName: packageName ?? this.packageName,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      clientEmail: clientEmail ?? this.clientEmail,
      clientAddress: clientAddress ?? this.clientAddress,
      venueLocation: venueLocation ?? this.venueLocation,
      preferredContact: preferredContact ?? this.preferredContact,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      eventStartTime: eventStartTime ?? this.eventStartTime,
      eventEndTime: eventEndTime ?? this.eventEndTime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      eventTheme: eventTheme ?? this.eventTheme,
      venueType: venueType ?? this.venueType,
      needsDecoration: needsDecoration ?? this.needsDecoration,
      needsEquipment: needsEquipment ?? this.needsEquipment,
      needsEntertainment: needsEntertainment ?? this.needsEntertainment,
      needsPhotography: needsPhotography ?? this.needsPhotography,
      needsCleanup: needsCleanup ?? this.needsCleanup,
      servicesNotes: servicesNotes ?? this.servicesNotes,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      depositAmount: depositAmount ?? this.depositAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentSchedule: paymentSchedule ?? this.paymentSchedule,
      specialRequests: specialRequests ?? this.specialRequests,
      accessibilityRequirements: accessibilityRequirements ?? this.accessibilityRequirements,
      contactPerson: contactPerson ?? this.contactPerson,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_id': packageId,
      'package_name': packageName,
      'client_name': clientName,
      'client_phone': clientPhone,
      'client_email': clientEmail,
      'client_address': clientAddress,
      'venue_location': venueLocation,
      'preferred_contact': preferredContact,
      'event_type': eventType,
      'event_date': eventDate.toIso8601String().split('T')[0],
      'event_start_time': eventStartTime,
      'event_end_time': eventEndTime,
      'number_of_guests': numberOfGuests,
      'event_theme': eventTheme,
      'venue_type': venueType,
      'needs_decoration': needsDecoration ? 1 : 0,
      'needs_equipment': needsEquipment ? 1 : 0,
      'needs_entertainment': needsEntertainment ? 1 : 0,
      'needs_photography': needsPhotography ? 1 : 0,
      'needs_cleanup': needsCleanup ? 1 : 0,
      'services_notes': servicesNotes,
      'estimated_budget': estimatedBudget,
      'deposit_amount': depositAmount,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'payment_schedule': paymentSchedule,
      'special_requests': specialRequests,
      'accessibility_requirements': accessibilityRequirements,
      'contact_person': contactPerson,
      'status': status,
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    String dateStr = json['event_date'] ?? json['date'] ?? '';
    DateTime date;
    if (dateStr.contains('T')) {
      date = DateTime.parse(dateStr);
    } else {
      date = DateTime.parse(dateStr);
    }
    
    DateTime? parseDateTime(String? str) {
      if (str == null || str.isEmpty) return null;
      try {
        return DateTime.parse(str);
      } catch (e) {
        return null;
      }
    }
    
    return Reservation(
      id: json['id'].toString(),
      userId: (json['user_id'] ?? json['userId'] ?? 0) as int,
      packageId: json['package_id'] ?? json['packageId'] ?? '',
      packageName: json['package_name'] ?? json['packageName'] ?? '',
      clientName: json['client_name'] ?? json['clientName'] ?? '',
      clientPhone: json['client_phone'] ?? json['clientPhone'],
      clientEmail: json['client_email'] ?? json['clientEmail'],
      clientAddress: json['client_address'] ?? json['clientAddress'],
      venueLocation: json['venue_location'] ?? json['venueLocation'],
      preferredContact: json['preferred_contact'] ?? json['preferredContact'] ?? 'phone',
      eventType: json['event_type'] ?? json['eventType'],
      eventDate: date,
      eventStartTime: json['event_start_time'] ?? json['eventStartTime'],
      eventEndTime: json['event_end_time'] ?? json['eventEndTime'],
      numberOfGuests: (json['number_of_guests'] ?? json['guests'] ?? json['numberOfGuests'] ?? 0) as int,
      eventTheme: json['event_theme'] ?? json['eventTheme'],
      venueType: json['venue_type'] ?? json['venueType'],
      needsDecoration: (json['needs_decoration'] ?? json['needsDecoration'] ?? 0) == 1,
      needsEquipment: (json['needs_equipment'] ?? json['needsEquipment'] ?? 0) == 1,
      needsEntertainment: (json['needs_entertainment'] ?? json['needsEntertainment'] ?? 0) == 1,
      needsPhotography: (json['needs_photography'] ?? json['needsPhotography'] ?? 0) == 1,
      needsCleanup: (json['needs_cleanup'] ?? json['needsCleanup'] ?? 0) == 1,
      servicesNotes: json['services_notes'] ?? json['servicesNotes'],
      estimatedBudget: json['estimated_budget'] != null ? (json['estimated_budget'] as num).toDouble() : null,
      depositAmount: (json['deposit_amount'] ?? json['depositAmount'] ?? 0.0) as double,
      totalAmount: json['total_amount'] != null ? (json['total_amount'] as num).toDouble() : null,
      paymentMethod: json['payment_method'] ?? json['paymentMethod'],
      paymentStatus: json['payment_status'] ?? json['paymentStatus'] ?? 'Pending',
      paymentSchedule: json['payment_schedule'] ?? json['paymentSchedule'],
      specialRequests: json['special_requests'] ?? json['specialRequests'] ?? json['notes'],
      accessibilityRequirements: json['accessibility_requirements'] ?? json['accessibilityRequirements'],
      contactPerson: json['contact_person'] ?? json['contactPerson'],
      status: json['status'] ?? 'Pending',
      approvedBy: json['approved_by'] != null ? (json['approved_by'] as num).toInt() : null,
      approvedAt: parseDateTime(json['approved_at'] ?? json['approvedAt']),
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

// ============================================
// INVENTORY MODEL
// ============================================
class InventoryItem {
  final String id;
  final String itemName;
  final String? category;
  final String? description;
  final int quantityAvailable;
  final int quantityReserved;
  final double unitPrice;
  final int reorderLevel;
  final String? supplier;
  final DateTime? lastRestocked;

  const InventoryItem({
    required this.id,
    required this.itemName,
    this.category,
    this.description,
    required this.quantityAvailable,
    this.quantityReserved = 0,
    this.unitPrice = 0.0,
    this.reorderLevel = 10,
    this.supplier,
    this.lastRestocked,
  });

  int get quantityTotal => quantityAvailable + quantityReserved;
  bool get needsReorder => quantityAvailable <= reorderLevel;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'].toString(),
      itemName: json['item_name'] ?? json['itemName'] ?? '',
      category: json['category'],
      description: json['description'],
      quantityAvailable: (json['quantity_available'] ?? json['quantityAvailable'] ?? 0) as int,
      quantityReserved: (json['quantity_reserved'] ?? json['quantityReserved'] ?? 0) as int,
      unitPrice: (json['unit_price'] ?? json['unitPrice'] ?? 0.0) as double,
      reorderLevel: (json['reorder_level'] ?? json['reorderLevel'] ?? 10) as int,
      supplier: json['supplier'],
      lastRestocked: json['last_restocked'] != null 
          ? DateTime.parse(json['last_restocked']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_name': itemName,
      'category': category,
      'description': description,
      'quantity_available': quantityAvailable,
      'quantity_reserved': quantityReserved,
      'unit_price': unitPrice,
      'reorder_level': reorderLevel,
      'supplier': supplier,
      'last_restocked': lastRestocked?.toIso8601String().split('T')[0],
    };
  }
}

// ============================================
// EMPLOYEE TASK MODEL
// ============================================
class EmployeeTask {
  final String id;
  final String reservationId;
  final int assignedTo;
  final String taskType;
  final String taskDescription;
  final DateTime scheduledDate;
  final String? scheduledTime;
  final String status;
  final String priority;
  final DateTime? completedAt;
  final String? completionNotes;
  final int? createdBy;

  const EmployeeTask({
    required this.id,
    required this.reservationId,
    required this.assignedTo,
    required this.taskType,
    required this.taskDescription,
    required this.scheduledDate,
    this.scheduledTime,
    this.status = 'Pending',
    this.priority = 'Medium',
    this.completedAt,
    this.completionNotes,
    this.createdBy,
  });

  factory EmployeeTask.fromJson(Map<String, dynamic> json) {
    return EmployeeTask(
      id: json['id'].toString(),
      reservationId: json['reservation_id'].toString(),
      assignedTo: (json['assigned_to'] ?? json['assignedTo'] ?? 0) as int,
      taskType: json['task_type'] ?? json['taskType'] ?? '',
      taskDescription: json['task_description'] ?? json['taskDescription'] ?? '',
      scheduledDate: DateTime.parse(json['scheduled_date'] ?? json['scheduledDate']),
      scheduledTime: json['scheduled_time'] ?? json['scheduledTime'],
      status: json['status'] ?? 'Pending',
      priority: json['priority'] ?? 'Medium',
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      completionNotes: json['completion_notes'] ?? json['completionNotes'],
      createdBy: json['created_by'] != null ? (json['created_by'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'assigned_to': assignedTo,
      'task_type': taskType,
      'task_description': taskDescription,
      'scheduled_date': scheduledDate.toIso8601String().split('T')[0],
      'scheduled_time': scheduledTime,
      'status': status,
      'priority': priority,
      'completion_notes': completionNotes,
    };
  }
}

// ============================================
// PAYMENT MODEL
// ============================================
class Payment {
  final String id;
  final String reservationId;
  final int userId;
  final double amount;
  final String paymentType;
  final String paymentMethod;
  final String? transactionReference;
  final DateTime paymentDate;
  final String status;
  final String? notes;

  const Payment({
    required this.id,
    required this.reservationId,
    required this.userId,
    required this.amount,
    required this.paymentType,
    required this.paymentMethod,
    this.transactionReference,
    required this.paymentDate,
    this.status = 'Completed',
    this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'].toString(),
      reservationId: json['reservation_id'].toString(),
      userId: (json['user_id'] ?? json['userId'] ?? 0) as int,
      amount: (json['amount'] as num).toDouble(),
      paymentType: json['payment_type'] ?? json['paymentType'] ?? '',
      paymentMethod: json['payment_method'] ?? json['paymentMethod'] ?? '',
      transactionReference: json['transaction_reference'] ?? json['transactionReference'],
      paymentDate: DateTime.parse(json['payment_date'] ?? json['paymentDate']),
      status: json['status'] ?? 'Completed',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      'user_id': userId,
      'amount': amount,
      'payment_type': paymentType,
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'payment_date': paymentDate.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }
}

// ============================================
// EXPENSE MODEL
// ============================================
class Expense {
  final String id;
  final String category;
  final String description;
  final double amount;
  final DateTime expenseDate;
  final String? vendor;
  final String? invoiceNumber;
  final String? reservationId;
  final String status;
  final int? approvedBy;
  final DateTime? approvedAt;

  const Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.expenseDate,
    this.vendor,
    this.invoiceNumber,
    this.reservationId,
    this.status = 'Pending',
    this.approvedBy,
    this.approvedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'].toString(),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expense_date'] ?? json['expenseDate']),
      vendor: json['vendor'],
      invoiceNumber: json['invoice_number'] ?? json['invoiceNumber'],
      reservationId: json['reservation_id']?.toString(),
      status: json['status'] ?? 'Pending',
      approvedBy: json['approved_by'] != null ? (json['approved_by'] as num).toInt() : null,
      approvedAt: json['approved_at'] != null 
          ? DateTime.parse(json['approved_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'amount': amount,
      'expense_date': expenseDate.toIso8601String().split('T')[0],
      'vendor': vendor,
      'invoice_number': invoiceNumber,
      'reservation_id': reservationId,
      'status': status,
    };
  }
}

