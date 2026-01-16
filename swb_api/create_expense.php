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

$category = trim($data['category'] ?? '');
$description = trim($data['description'] ?? '');
$amount = floatval($data['amount'] ?? 0.00);
$expense_date = trim($data['expense_date'] ?? date('Y-m-d'));
$vendor = trim($data['vendor'] ?? '');
$invoice_number = trim($data['invoice_number'] ?? '');
$reservation_id = isset($data['reservation_id']) ? intval($data['reservation_id']) : null;
$created_by = intval($data['created_by'] ?? 0);

if (empty($category) || empty($description) || $amount <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Required fields: category, description, amount"
    ]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO expenses (category, description, amount, expense_date, vendor, invoice_number, reservation_id, created_by, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Pending')");
$stmt->bind_param("ssdsssii", $category, $description, $amount, $expense_date, $vendor, $invoice_number, $reservation_id, $created_by);

if ($stmt->execute()) {
    $expense_id = $conn->insert_id;
    echo json_encode([
        "success" => true,
        "message" => "Expense recorded successfully",
        "expense_id" => $expense_id
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to record expense: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
