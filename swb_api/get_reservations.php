<?php
include 'db.php';

header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Get user_id from query parameter (optional - if provided, returns only that user's reservations)
$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;

if ($user_id !== null) {
    // Get reservations for a specific user
    $stmt = $conn->prepare("SELECT id, user_id, package_id, package_name, date, guests, notes, status FROM reservations WHERE user_id = ? ORDER BY date ASC");
    $stmt->bind_param("i", $user_id);
} else {
    // Get all reservations (for staff)
    $stmt = $conn->prepare("SELECT id, user_id, package_id, package_name, date, guests, notes, status FROM reservations ORDER BY date ASC");
}

$stmt->execute();
$result = $stmt->get_result();

$reservations = [];
while ($row = $result->fetch_assoc()) {
    $reservations[] = [
        "id" => strval($row['id']),
        "user_id" => $row['user_id'],
        "package_id" => $row['package_id'],
        "package_name" => $row['package_name'],
        "date" => $row['date'],
        "guests" => $row['guests'],
        "notes" => $row['notes'] ?? '',
        "status" => $row['status'] ?? 'Pending'
    ];
}

echo json_encode([
    "success" => true,
    "reservations" => $reservations
]);

$stmt->close();
$conn->close();
?>
