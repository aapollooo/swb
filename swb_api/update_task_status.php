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

$task_id = intval($data['task_id'] ?? 0);
$status = trim($data['status'] ?? '');
$completion_notes = trim($data['completion_notes'] ?? '');

if ($task_id <= 0 || empty($status)) {
    echo json_encode([
        "success" => false,
        "message" => "Task ID and status are required"
    ]);
    exit;
}

$allowed_statuses = ['Pending', 'In Progress', 'Completed', 'Cancelled'];
if (!in_array($status, $allowed_statuses)) {
    echo json_encode([
        "success" => false,
        "message" => "Invalid status"
    ]);
    exit;
}

$completed_at = ($status === 'Completed') ? date('Y-m-d H:i:s') : null;

$stmt = $conn->prepare("UPDATE employee_tasks SET status = ?, completion_notes = ?, completed_at = ? WHERE id = ?");
$stmt->bind_param("sssi", $status, $completion_notes, $completed_at, $task_id);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Task status updated successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to update task: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
