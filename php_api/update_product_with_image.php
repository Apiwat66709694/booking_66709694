<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include 'condb.php';
header('Content-Type: application/json');

try {

    ////////////////////////////////////////////////////////////
    // ✅ รับค่า (equipment)
    ////////////////////////////////////////////////////////////

    $id      = $_POST['id'];
    $eq_name = $_POST['eq_name'];
    $detail  = $_POST['detail'];
    $num     = $_POST['num'];
    $oldImage = $_POST['old_image'];

    $imageName = $oldImage;

    ////////////////////////////////////////////////////////////
    // ✅ อัปโหลดรูปใหม่
    ////////////////////////////////////////////////////////////

    if (isset($_FILES['image'])) {

        $targetDir = "images/";
        $imageName = time() . "_" . basename($_FILES["image"]["name"]); // ✅ แก้ตรงนี้
        $targetFile = $targetDir . $imageName;

        if (move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {

            // ลบรูปเก่า
            if ($oldImage != "" && file_exists($targetDir . $oldImage)) {
                unlink($targetDir . $oldImage);
            }

        } else {
            echo json_encode([
                "success" => false,
                "error" => "Upload failed"
            ]);
            exit;
        }
    }

    ////////////////////////////////////////////////////////////
    // ✅ UPDATE DB
    ////////////////////////////////////////////////////////////

    $sql = "UPDATE equipment 
            SET eq_name = :eq_name,
                detail  = :detail,
                num     = :num,
                image   = :image
            WHERE id = :id";

    $stmt = $conn->prepare($sql);

    $stmt->bindParam(':id', $id);
    $stmt->bindParam(':eq_name', $eq_name);
    $stmt->bindParam(':detail', $detail);
    $stmt->bindParam(':num', $num);
    $stmt->bindParam(':image', $imageName);

    $stmt->execute();

    echo json_encode(["success" => true]);

} catch (PDOException $e) {

    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
}
?>