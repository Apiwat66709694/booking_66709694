<?php

header("Content-Type: application/json; charset=UTF-8");
include "condb.php";

try {

    $sql = "SELECT 
                id,
                product_name,
                detail,
                price,
                stock,
                image,
                created_at
            FROM products
            ORDER BY id DESC";

    $stmt = $conn->query($sql);
    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($data, JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {

    echo json_encode([
        "error" => $e->getMessage()
    ]);
}
?>