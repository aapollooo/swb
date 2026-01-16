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

// Optional filters
$assigned_to = isset($_GET['assigned_to']) ? intval($_GET['assigned_to']) : null;
$reservation_id = isset($_GET['reservation_id']) ? intval($_GET['reservation_id']) : null;
$status = isset($_GET['status']) ? trim($_GET['status']) : null;
$date_from = isset($_GET['date_from']) ? trim($_GET['date_from']) : null;
$date_to = isset($_GET['date_to']) ? trim($_GET['date_to']) : null;

$sql = "SELECT t.id, t.reservation_id, t.assigned_to, t.task_type, t.task_description, 
        t.scheduled_date, t.scheduled_time, t.status, t.priority, t.completed_at, 
        t.completion_notes, t.created_by, u.full_name as assigned_to_name,
        r.client_name, r.event_date
        FROM employee_tasks t
        LEFT JOIN users u ON t.assigned_to = u.id
        LEFT JOIN reservations r ON t.reservation_id = r.id
        WHERE 1=1";

$params = [];
$types = "";

if ($assigned_to !== null) {
    $sql .= " AND t.assigned_to = ?";
    $params[] = $assigned_to;
    $types .= "i";
}

if ($reservation_id !== null) {
    $sql .= " AND t.reservation_id = ?";
    $params[] = $reservation_id;
    $types .= "i";
}

if ($status !== null && $status !== '') {
    $sql .= " AND t.status = ?";
    $params[] = $status;
    $types .= "s";
}

if ($date_from !== null) {
    $sql .= " AND t.scheduled_date >= ?";
    $params[] = $date_from;
    $types .= "s";
}

if ($date_to !== null) {
    $sql .= " AND t.scheduled_date <= ?";
    $params[] = $date_to;
    $types .= "s";
}

$sql .= " ORDER BY t.scheduled_date ASC, t.scheduled_time ASC";

$stmt = $conn->prepare($sql);
if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}

$stmt->execute();
$result = $stmt->get_result();

$tasks = [];
while ($row = $result->fetch_assoc()) {
    $tasks[] = [
        "id" => $row['id'],
        "reservation_id" => $row['reservation_id'],
        "assigned_to" => $row['assigned_to'],
        "assigned_to_name" => $row['assigned_to_name'],
        "task_type" => $row['task_type'],
        "task_description" => $row['task_description'],
        "scheduled_date" => $row['scheduled_date'],
        "scheduled_time" => $row['scheduled_time'],
        "status" => $row['status'],
        "priority" => $row['priority'],
        "completed_at" => $row['completed_at'],
        "completion_notes" => $row['completion_notes'],
        "created_by" => $row['created_by'],
        "client_name" => $row['client_name'],
        "event_date" => $row['event_date'],
    ];
}

echo json_encode([
    "success" => true,
    "tasks" => $tasks
]);

$stmt->close();
$conn->close();
?>
