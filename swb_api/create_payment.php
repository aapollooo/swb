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

$data = json_decode(file_get_contents("php://input"), true);

$reservation_id = intval($data['reservation_id'] ?? 0);
$user_id = intval($data['user_id'] ?? 0);
$amount = floatval($data['amount'] ?? 0.00);
$payment_type = trim($data['payment_type'] ?? '');
$payment_method = trim($data['payment_method'] ?? '');
$transaction_reference = trim($data['transaction_reference'] ?? '');
$payment_date = trim($data['payment_date'] ?? date('Y-m-d H:i:s'));
$notes = trim($data['notes'] ?? '');
$recorded_by = intval($data['recorded_by'] ?? 0);

if ($reservation_id <= 0 || $user_id <= 0 || $amount <= 0 || empty($payment_type) || empty($payment_method)) {
    echo json_encode([
        "success" => false,
        "message" => "Required fields: reservation_id, user_id, amount, payment_type, payment_method"
    ]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO payments (reservation_id, user_id, amount, payment_type, payment_method, transaction_reference, payment_date, notes, recorded_by, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Completed')");
$stmt->bind_param("iidsssssi", $reservation_id, $user_id, $amount, $payment_type, $payment_method, $transaction_reference, $payment_date, $notes, $recorded_by);

if ($stmt->execute()) {
    $payment_id = $conn->insert_id;
    
    // Update reservation payment status
    $update_reservation = $conn->prepare("UPDATE reservations SET payment_status = 'Completed' WHERE id = ?");
    $update_reservation->bind_param("i", $reservation_id);
    $update_reservation->execute();
    $update_reservation->close();
    
    echo json_encode([
        "success" => true,
        "message" => "Payment recorded successfully",
        "payment_id" => $payment_id
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to record payment: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
