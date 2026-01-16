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

$expense_id = intval($data['expense_id'] ?? 0);
$approved_by = intval($data['approved_by'] ?? 0);
$action = trim($data['action'] ?? ''); // 'approve' or 'reject'

if ($expense_id <= 0 || $approved_by <= 0 || empty($action)) {
    echo json_encode([
        "success" => false,
        "message" => "Required fields: expense_id, approved_by, action"
    ]);
    exit;
}

if ($action === 'approve') {
    $status = 'Approved';
    $approved_at = date('Y-m-d H:i:s');
    $stmt = $conn->prepare("UPDATE expenses SET status = ?, approved_by = ?, approved_at = ? WHERE id = ?");
    $stmt->bind_param("sisi", $status, $approved_by, $approved_at, $expense_id);
} else if ($action === 'reject') {
    $status = 'Rejected';
    $stmt = $conn->prepare("UPDATE expenses SET status = ?, approved_by = ?, approved_at = ? WHERE id = ?");
    $stmt->bind_param("sisi", $status, $approved_by, $approved_at, $expense_id);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Invalid action. Use 'approve' or 'reject'"
    ]);
    exit;
}

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Expense " . $action . "d successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to update expense: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
