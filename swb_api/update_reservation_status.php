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

$reservation_id = intval($data['reservation_id'] ?? 0);
$status = trim($data['status'] ?? '');

if ($reservation_id <= 0 || empty($status)) {
    echo json_encode([
        "success" => false,
        "message" => "Reservation ID and status are required"
    ]);
    exit;
}

// Validate status
$allowed_statuses = ['Pending', 'Approved', 'Completed'];
if (!in_array($status, $allowed_statuses)) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid status. Allowed values: Pending, Approved, Completed"
    ]);
    exit;
}

// Update reservation status
$stmt = $conn->prepare("UPDATE reservations SET status = ? WHERE id = ?");
$stmt->bind_param("si", $status, $reservation_id);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Reservation status updated successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to update status: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
