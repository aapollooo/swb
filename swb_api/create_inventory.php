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

$item_name = trim($data['item_name'] ?? '');
$category = trim($data['category'] ?? '');
$description = trim($data['description'] ?? '');
$quantity_available = intval($data['quantity_available'] ?? 0);
$unit_price = floatval($data['unit_price'] ?? 0.00);
$reorder_level = intval($data['reorder_level'] ?? 10);
$supplier = trim($data['supplier'] ?? '');

if (empty($item_name)) {
    echo json_encode([
        "success" => false,
        "message" => "Item name is required"
    ]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO inventory (item_name, category, description, quantity_available, unit_price, reorder_level, supplier, last_restocked) VALUES (?, ?, ?, ?, ?, ?, ?, CURDATE())");
$stmt->bind_param("sssidsis", $item_name, $category, $description, $quantity_available, $unit_price, $reorder_level, $supplier);

if ($stmt->execute()) {
    $item_id = $conn->insert_id;
    echo json_encode([
        "success" => true,
        "message" => "Inventory item created successfully",
        "item_id" => $item_id
    ]);
} else {
    echo json_encode([
        "success" => false,
        "message" => "Failed to create inventory item: " . $stmt->error
    ]);
}

$stmt->close();
$conn->close();
?>
