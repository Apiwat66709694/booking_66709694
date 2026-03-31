import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

const String baseUrl = "http://127.0.0.1/booking_66709694/php_api/";

class EditProductPage extends StatefulWidget {
  final dynamic product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {

  late TextEditingController nameController;
  late TextEditingController detailController;
  late TextEditingController stockController;

  XFile? selectedImage;

  @override
  void initState() {
    super.initState();

    ////////////////////////////////////////////////////////////
    // ✅ ใช้ key ให้ตรง DB
    ////////////////////////////////////////////////////////////

    nameController =
        TextEditingController(text: widget.product['eq_name'] ?? "");

    detailController =
        TextEditingController(text: widget.product['detail'] ?? "");

    stockController =
        TextEditingController(text: widget.product['num']?.toString() ?? "");
  }

  ////////////////////////////////////////////////////////////
  // 🖼 PICK IMAGE
  ////////////////////////////////////////////////////////////

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  // 💾 UPDATE
  ////////////////////////////////////////////////////////////

  Future<void> updateProduct() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${baseUrl}update_product_with_image.php"),
      );

      request.fields['id'] = widget.product['id'].toString();
      request.fields['eq_name'] = nameController.text;
      request.fields['detail'] = detailController.text;
      request.fields['num'] = stockController.text;
      request.fields['old_image'] = widget.product['image'] ?? "";

      if (selectedImage != null) {
        if (kIsWeb) {
          final bytes = await selectedImage!.readAsBytes();

          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: selectedImage!.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image',
              selectedImage!.path,
            ),
          );
        }
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      final data = json.decode(responseData);

      if (data["success"] == true) {
        if (!mounted) return;

        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("แก้ไขสินค้าเรียบร้อย")),
        );
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    String imageUrl = "${baseUrl}images/${widget.product['image']}";

    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไขสินค้า")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            children: [

              ////////////////////////////////////////////////////////////
              // 🖼 IMAGE
              ////////////////////////////////////////////////////////////

              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: selectedImage == null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : kIsWeb
                            ? Image.network(selectedImage!.path)
                            : Image.file(File(selectedImage!.path)),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ////////////////////////////////////////////////////////////
              // 🏷 NAME
              ////////////////////////////////////////////////////////////

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "ชื่อสินค้า",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 📝 DETAIL
              ////////////////////////////////////////////////////////////

              TextField(
                controller: detailController,
                decoration: const InputDecoration(
                  labelText: "รายละเอียด",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 📦 STOCK
              ////////////////////////////////////////////////////////////

              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "จำนวนสินค้า",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 25),

              ////////////////////////////////////////////////////////////
              // BUTTON
              ////////////////////////////////////////////////////////////

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateProduct,
                  child: const Text("บันทึก"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}