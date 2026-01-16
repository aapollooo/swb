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

$category = isset($_GET['category']) ? trim($_GET['category']) : null;
$status = isset($_GET['status']) ? trim($_GET['status']) : null;
$date_from = isset($_GET['date_from']) ? trim($_GET['date_from']) : null;
$date_to = isset($_GET['date_to']) ? trim($_GET['date_to']) : null;

$sql = "SELECT e.id, e.category, e.description, e.amount, e.expense_date, 
        e.vendor, e.invoice_number, e.reservation_id, e.status, e.approved_by, e.approved_at,
        r.client_name, r.event_date
        FROM expenses e
        LEFT JOIN reservations r ON e.reservation_id = r.id
        WHERE 1=1";

$params = [];
$types = "";

if ($category !== null && $category !== '') {
    $sql .= " AND e.category = ?";
    $params[] = $category;
    $types .= "s";
}

if ($status !== null && $status !== '') {
    $sql .= " AND e.status = ?";
    $params[] = $status;
    $types .= "s";
}

if ($date_from !== null) {
    $sql .= " AND e.expense_date >= ?";
    $params[] = $date_from;
    $types .= "s";
}

if ($date_to !== null) {
    $sql .= " AND e.expense_date <= ?";
    $params[] = $date_to;
    $types .= "s";
}

$sql .= " ORDER BY e.expense_date DESC";

$stmt = $conn->prepare($sql);
if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}

$stmt->execute();
$result = $stmt->get_result();

$expenses = [];
while ($row = $result->fetch_assoc()) {
    $expenses[] = [
        "id" => $row['id'],
        "category" => $row['category'],
        "description" => $row['description'],
        "amount" => floatval($row['amount']),
        "expense_date" => $row['expense_date'],
        "vendor" => $row['vendor'],
        "invoice_number" => $row['invoice_number'],
        "reservation_id" => $row['reservation_id'],
        "status" => $row['status'],
        "approved_by" => $row['approved_by'],
        "approved_at" => $row['approved_at'],
        "client_name" => $row['client_name'],
        "event_date" => $row['event_date'],
    ];
}

echo json_encode([
    "success" => true,
    "expenses" => $expenses
]);

$stmt->close();
$conn->close();
?>
