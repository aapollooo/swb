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

$item_id = intval($data['item_id'] ?? 0);
$quantity_available = isset($data['quantity_available']) ? intval($data['quantity_available']) : null;
$quantity_reserved = isset($data['quantity_reserved']) ? intval($data['quantity_reserved']) : null;
$unit_price = isset($data['unit_price']) ? floatval($data['unit_price']) : null;
$reorder_level = isset($data['reorder_level']) ? intval($data['reorder_level']) : null;

if ($item_id <= 0) {
    echo json_encode([
        "success" => false,
        "message" => "Item ID is required"
    ]);
    exit;
}

$updates = [];
$params = [];
$types = "";

if ($quantity_available !== null) {
    $updates[] = "quantity_available = ?";
    $params[] = $quantity_available;
    $types .= "i";
}

if ($quantity_reserved !== null) {
    $updates[] = "quantity_reserved = ?";
    $params[] = $quantity_reserved;
    $types .= "i";
}

if ($unit_price !== null) {
    $updates[] = "unit_price = ?";
    $params[] = $unit_price;
    $types .= "d";
}

if ($reorder_level !== null) {
    $updates[] = "reorder_level = ?";
    $params[] = $reorder_level;
    $types .= "i";
}

if (empty($updates)) {
    echo json_encode([
        "success" => false,
        "message" => "No fields to update"
    ]);
    exit;
}

$sql = "UPDATE inventory SET " . implode(", ", $updates) . " WHERE id = ?";
$params[] = $item_id;
$types .= "i";

$stmt = $conn->prepare($sql);
$stmt->bind_param($types, ...$params);

if ($stmt->execute()) {
    echo json_encode([
        "success" => true,
        "message" => "Inventory updated successfully"
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to update inventory: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
