<?php
include 'db.php';

header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get JSON input from Flutter
$data = json_decode(file_get_contents("php://input"), true);

// Required fields
$user_id = intval($data['user_id'] ?? 0);
$package_id = trim($data['package_id'] ?? '');
$package_name = trim($data['package_name'] ?? '');
$event_date = trim($data['event_date'] ?? $data['date'] ?? '');
$number_of_guests = intval($data['number_of_guests'] ?? $data['guests'] ?? 0);
$client_name = trim($data['client_name'] ?? '');

if (empty($package_id) || empty($package_name) || empty($event_date) || $number_of_guests <= 0 || $user_id <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Required fields: user_id, package_id, package_name, event_date, number_of_guests"
    ]);
    exit;
}

// Optional fields with defaults (backward compatible)
$client_phone = trim($data['client_phone'] ?? '');
$client_email = trim($data['client_email'] ?? '');
$client_address = trim($data['client_address'] ?? '');
$venue_location = trim($data['venue_location'] ?? '');
$preferred_contact = trim($data['preferred_contact'] ?? 'phone');
$event_type = trim($data['event_type'] ?? '');
$event_start_time = trim($data['event_start_time'] ?? null);
$event_end_time = trim($data['event_end_time'] ?? null);
$event_theme = trim($data['event_theme'] ?? '');
$venue_type = trim($data['venue_type'] ?? '');
$needs_decoration = isset($data['needs_decoration']) ? (intval($data['needs_decoration']) ? 1 : 0) : 0;
$needs_equipment = isset($data['needs_equipment']) ? (intval($data['needs_equipment']) ? 1 : 0) : 0;
$needs_entertainment = isset($data['needs_entertainment']) ? (intval($data['needs_entertainment']) ? 1 : 0) : 0;
$needs_photography = isset($data['needs_photography']) ? (intval($data['needs_photography']) ? 1 : 0) : 0;
$needs_cleanup = isset($data['needs_cleanup']) ? (intval($data['needs_cleanup']) ? 1 : 0) : 0;
$services_notes = trim($data['services_notes'] ?? '');
$estimated_budget = isset($data['estimated_budget']) ? floatval($data['estimated_budget']) : null;
$deposit_amount = isset($data['deposit_amount']) ? floatval($data['deposit_amount']) : 0.00;
$total_amount = isset($data['total_amount']) ? floatval($data['total_amount']) : null;
$payment_method = trim($data['payment_method'] ?? '');
$payment_status = trim($data['payment_status'] ?? 'Pending');
$payment_schedule = trim($data['payment_schedule'] ?? '');
$special_requests = trim($data['special_requests'] ?? $data['notes'] ?? '');
$accessibility_requirements = trim($data['accessibility_requirements'] ?? '');
$contact_person = trim($data['contact_person'] ?? '');

// Use client_name from data or get from users table
if (empty($client_name)) {
    $user_query = $conn->prepare("SELECT full_name FROM users WHERE id = ?");
    $user_query->bind_param("i", $user_id);
    $user_query->execute();
    $user_result = $user_query->get_result();
    if ($user_row = $user_result->fetch_assoc()) {
        $client_name = $user_row['full_name'];
    }
    $user_query->close();
}

// Check if expanded table exists, use appropriate INSERT
$table_check = $conn->query("SHOW COLUMNS FROM reservations LIKE 'client_name'");
if ($table_check && $table_check->num_rows > 0) {
    // Expanded table exists - use all fields
    $sql = "INSERT INTO reservations (
        user_id, package_id, package_name, client_name, client_phone, client_email, 
        client_address, venue_location, preferred_contact, event_type, event_date, 
        event_start_time, event_end_time, number_of_guests, event_theme, venue_type,
        needs_decoration, needs_equipment, needs_entertainment, needs_photography, 
        needs_cleanup, services_notes, estimated_budget, deposit_amount, total_amount,
        payment_method, payment_status, payment_schedule, special_requests,
        accessibility_requirements, contact_person, status
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending')";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("issssssssssssssssiiiiisddddsssssss",
        $user_id, $package_id, $package_name, $client_name, $client_phone, $client_email,
        $client_address, $venue_location, $preferred_contact, $event_type, $event_date,
        $event_start_time, $event_end_time, $number_of_guests, $event_theme, $venue_type,
        $needs_decoration, $needs_equipment, $needs_entertainment, $needs_photography,
        $needs_cleanup, $services_notes, $estimated_budget, $deposit_amount, $total_amount,
        $payment_method, $payment_status, $payment_schedule, $special_requests,
        $accessibility_requirements, $contact_person
    );
} else {
    // Old table structure - backward compatibility
    $stmt = $conn->prepare("INSERT INTO reservations (user_id, package_id, package_name, date, guests, notes, status) VALUES (?, ?, ?, ?, ?, ?, 'Pending')");
    $stmt->bind_param("isssis", $user_id, $package_id, $package_name, $event_date, $number_of_guests, $special_requests);
}

if ($stmt->execute()) {
    $reservation_id = $conn->insert_id;
    echo json_encode([
        "success" => true,
        "message" => "Reservation created successfully",
        "reservation_id" => $reservation_id
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to create reservation: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
