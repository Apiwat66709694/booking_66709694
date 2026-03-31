<?php
include 'condb.php';

header('Content-Type: application/json');

////////////////////////////////////////////////////////////
// ✅ รับค่าจาก Flutter
////////////////////////////////////////////////////////////

$eq_name = $_POST['eq_name'] ?? '';
$detail  = $_POST['detail'] ?? '';
$num     = $_POST['num'] ?? '';

////////////////////////////////////////////////////////////
// ✅ รับรูปภาพ
////////////////////////////////////////////////////////////

$imageName = "";

if (isset($_FILES['image'])) {

    $targetDir = "images/";
    $imageName = time() . "_" . basename($_FILES["image"]["name"]);
    $targetFile = $targetDir . $imageName;

    if (!move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {
        echo json_encode([
            "success" => false,
            "error" => "Upload image failed"
        ]);
        exit;
    }
}

////////////////////////////////////////////////////////////
// ✅ Insert DB (equipment)
////////////////////////////////////////////////////////////

try {

    $stmt = $conn->prepare("
        INSERT INTO equipment (eq_name, detail, num, image)
        VALUES (:eq_name, :detail, :num, :image)
    ");

    $stmt->bindParam(":eq_name", $eq_name);
    $stmt->bindParam(":detail", $detail);
    $stmt->bindParam(":num", $num);
    $stmt->bindParam(":image", $imageName);

    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false]);
    }

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
}
?>