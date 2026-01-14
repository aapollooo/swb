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

// Validate input
$package_id = trim($data['package_id'] ?? '');
$package_name = trim($data['package_name'] ?? '');
$date = trim($data['date'] ?? '');
$guests = intval($data['guests'] ?? 0);
$notes = trim($data['notes'] ?? '');
$user_id = intval($data['user_id'] ?? 0);

if (empty($package_id) || empty($package_name) || empty($date) || $guests <= 0 || $user_id <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "All required fields must be provided"
    ]);
    exit;
}

// Insert reservation into database
$stmt = $conn->prepare("INSERT INTO reservations (user_id, package_id, package_name, date, guests, notes, status) VALUES (?, ?, ?, ?, ?, ?, 'Pending')");
$stmt->bind_param("isssis", $user_id, $package_id, $package_name, $date, $guests, $notes);

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
