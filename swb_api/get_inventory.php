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
$category = isset($_GET['category']) ? trim($_GET['category']) : null;
$low_stock_only = isset($_GET['low_stock']) && $_GET['low_stock'] == '1';

$sql = "SELECT id, item_name, category, description, quantity_available, quantity_reserved, 
        unit_price, reorder_level, supplier, last_restocked 
        FROM inventory WHERE 1=1";

$params = [];
$types = "";

if ($category !== null && $category !== '') {
    $sql .= " AND category = ?";
    $params[] = $category;
    $types .= "s";
}

if ($low_stock_only) {
    $sql .= " AND quantity_available <= reorder_level";
}

$sql .= " ORDER BY item_name ASC";

$stmt = $conn->prepare($sql);
if (!empty($params)) {
    $stmt->bind_param($types, ...$params);
}

$stmt->execute();
$result = $stmt->get_result();

$inventory = [];
while ($row = $result->fetch_assoc()) {
    $inventory[] = [
        "id" => $row['id'],
        "item_name" => $row['item_name'],
        "category" => $row['category'],
        "description" => $row['description'],
        "quantity_available" => $row['quantity_available'],
        "quantity_reserved" => $row['quantity_reserved'],
        "unit_price" => floatval($row['unit_price']),
        "reorder_level" => $row['reorder_level'],
        "supplier" => $row['supplier'],
        "last_restocked" => $row['last_restocked'],
    ];
}

echo json_encode([
    "success" => true,
    "inventory" => $inventory
]);

$stmt->close();
$conn->close();
?>
