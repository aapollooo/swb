<?php
include 'db.php';

$data = json_decode(file_get_contents("php://input"), true);

$email = trim($data['email'] ?? '');
$password = trim($data['password'] ?? '');

if ($email === '' || $password === '') {
    echo json_encode(["success" => false, "message" => "All fields are required"]);
    exit;
}

$sql = "SELECT id, full_name, password, role FROM users WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {
    $user = $result->fetch_assoc();

    if (password_verify($password, $user['password'])) {

        // generate token
        $token = bin2hex(random_bytes(32));

        // save token
        $update = $conn->prepare("UPDATE users SET api_token=? WHERE id=?");
        $update->bind_param("si", $token, $user['id']);
        $update->execute();

        echo json_encode([
            "success" => true,
            "token" => $token,
            "user" => [
                "id" => $user['id'],
                "full_name" => $user['full_name'],
                "email" => $email,
                "role" => $user['role'] ?? 'customer'
            ]
        ]);
        exit;
    }
}

echo json_encode(["success" => false, "message" => "Invalid credentials"]);
