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

$date_from = isset($_GET['date_from']) ? trim($_GET['date_from']) : date('Y-m-01'); // First day of current month
$date_to = isset($_GET['date_to']) ? trim($_GET['date_to']) : date('Y-m-t'); // Last day of current month

// Total Revenue
$revenue_query = $conn->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE DATE(payment_date) BETWEEN ? AND ? AND status = 'Completed'");
$revenue_query->bind_param("ss", $date_from, $date_to);
$revenue_query->execute();
$revenue_result = $revenue_query->get_result();
$total_revenue = $revenue_result->fetch_assoc()['total'];
$revenue_query->close();

// Total Expenses
$expense_query = $conn->prepare("SELECT COALESCE(SUM(amount), 0) as total FROM expenses WHERE expense_date BETWEEN ? AND ? AND status = 'Approved'");
$expense_query->bind_param("ss", $date_from, $date_to);
$expense_query->execute();
$expense_result = $expense_query->get_result();
$total_expenses = $expense_result->fetch_assoc()['total'];
$expense_query->close();

// Total Reservations
$reservation_query = $conn->prepare("SELECT COUNT(*) as total FROM reservations WHERE event_date BETWEEN ? AND ?");
$reservation_query->bind_param("ss", $date_from, $date_to);
$reservation_query->execute();
$reservation_result = $reservation_query->get_result();
$total_reservations = $reservation_result->fetch_assoc()['total'];
$reservation_query->close();

// Pending Reservations
$pending_query = $conn->prepare("SELECT COUNT(*) as total FROM reservations WHERE status = 'Pending'");
$pending_query->execute();
$pending_result = $pending_query->get_result();
$pending_reservations = $pending_result->fetch_assoc()['total'];
$pending_query->close();

// Low Stock Items
$low_stock_query = $conn->query("SELECT COUNT(*) as total FROM inventory WHERE quantity_available <= reorder_level");
$low_stock_result = $low_stock_query->fetch_assoc();
$low_stock_items = $low_stock_result['total'];
$low_stock_query->close();

// Pending Tasks
$pending_tasks_query = $conn->query("SELECT COUNT(*) as total FROM employee_tasks WHERE status IN ('Pending', 'In Progress')");
$pending_tasks_result = $pending_tasks_query->fetch_assoc();
$pending_tasks = $pending_tasks_result['total'];
$pending_tasks_query->close();

// Pending Expenses (for approval)
$pending_expenses_query = $conn->query("SELECT COUNT(*) as total FROM expenses WHERE status = 'Pending'");
$pending_expenses_result = $pending_expenses_query->fetch_assoc();
$pending_expenses = $pending_expenses_result['total'];
$pending_expenses_query->close();

$profit = floatval($total_revenue) - floatval($total_expenses);

echo json_encode([
    "success" => true,
    "stats" => [
        "total_revenue" => floatval($total_revenue),
        "total_expenses" => floatval($total_expenses),
        "profit" => $profit,
        "total_reservations" => intval($total_reservations),
        "pending_reservations" => intval($pending_reservations),
        "low_stock_items" => intval($low_stock_items),
        "pending_tasks" => intval($pending_tasks),
        "pending_expenses" => intval($pending_expenses),
        "date_from" => $date_from,
        "date_to" => $date_to,
    ]
]);

$conn->close();
?>
