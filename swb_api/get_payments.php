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

$reservation_id = isset($_GET['reservation_id']) ? intval($_GET['reservation_id']) : null;
$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : null;
$date_from = isset($_GET['date_from']) ? trim($_GET['date_from']) : null;
$date_to = isset($_GET['date_to']) ? trim($_GET['date_to']) : null;

$sql = "SELECT p.id, p.reservation_id, p.user_id, p.amount, p.payment_type, 
        p.payment_method, p.transaction_reference, p.payment_date, p.status, p.notes,
        r.client_name, r.event_date
        FROM payments p
        LEFT JOIN reservations r ON p.reservation_id = r.id
        WHERE 1=1";

$params = [];
$types = "";

if ($reservation_id !== null) {
    $sql .= " AND p.reservation_id = ?";
    $params[] = $reservation_id;
    $types .= "i";
}

if ($user_id !== null) {
    $sql .= " AND p.user_id = ?";
    $params[] = $user_id;
    $types .= "i";
}

if ($date_from !== null) {
    $sql .= " AND DATE(p.payment_date) >= ?";
    $params[] = $date_from;
    $types .= "s";
}

if ($date_to !== null) {
    $sql .= " AND DATE(p.payment_date) <= ?";
    $params[] = $date_to;
    $types .= "s";
}

$sql .= " ORDER BY p.payment_date DESC";

$stmt = $conn->prepare($sql);
if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}

$stmt->execute();
$result = $stmt->get_result();

$payments = [];
while ($row = $result->fetch_assoc()) {
    $payments[] = [
        "id" => $row['id'],
        "reservation_id" => $row['reservation_id'],
        "user_id" => $row['user_id'],
        "amount" => floatval($row['amount']),
        "payment_type" => $row['payment_type'],
        "payment_method" => $row['payment_method'],
        "transaction_reference" => $row['transaction_reference'],
        "payment_date" => $row['payment_date'],
        "status" => $row['status'],
        "notes" => $row['notes'],
        "client_name" => $row['client_name'],
        "event_date" => $row['event_date'],
    ];
}

echo json_encode([
    "success" => true,
    "payments" => $payments
]);

$stmt->close();
$conn->close();
?>
