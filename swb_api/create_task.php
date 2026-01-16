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
$assigned_to = intval($data['assigned_to'] ?? 0);
$task_type = trim($data['task_type'] ?? '');
$task_description = trim($data['task_description'] ?? '');
$scheduled_date = trim($data['scheduled_date'] ?? '');
$scheduled_time = trim($data['scheduled_time'] ?? null);
$priority = trim($data['priority'] ?? 'Medium');
$created_by = intval($data['created_by'] ?? 0);

if ($reservation_id <= 0 || $assigned_to <= 0 || empty($task_type) || empty($task_description) || empty($scheduled_date)) {
    echo json_encode([
        "success" => false,
        "message" => "Required fields: reservation_id, assigned_to, task_type, task_description, scheduled_date"
    ]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO employee_tasks (reservation_id, assigned_to, task_type, task_description, scheduled_date, scheduled_time, priority, created_by, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'Pending')");
$stmt->bind_param("iisssssi", $reservation_id, $assigned_to, $task_type, $task_description, $scheduled_date, $scheduled_time, $priority, $created_by);

if ($stmt->execute()) {
    $task_id = $conn->insert_id;
    echo json_encode([
        "success" => true,
        "message" => "Task created successfully",
        "task_id" => $task_id
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to create task: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
