import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

const String baseUrl = "http://127.0.0.1/booking_66709694/php_api/";

class EditProductPage extends StatefulWidget {
  final dynamic product; // ข้อมูลที่ส่งมาจากหน้า List

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController nameController;
  late TextEditingController capacityController;
  late TextEditingController locationController;

  XFile? selectedImage;

  @override
  void initState() {
    super.initState();
    
    // ✅ แก้ไขตรงนี้: ใช้ Key ให้ตรงกับที่ฐานข้อมูล/API ส่งมา
    // สมมติว่าในฐานข้อมูลใช้ชื่อคอลัมน์ room_name, capacity, location
    nameController = TextEditingController(text: widget.product['room_name']?.toString() ?? "");
    capacityController = TextEditingController(text: widget.product['capacity']?.toString() ?? "");
    locationController = TextEditingController(text: widget.product['location']?.toString() ?? "");
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  Future<void> updateProduct() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${baseUrl}update_product_with_image.php"),
      );

      // ส่งข้อมูลไปยัง PHP
      request.fields['id'] = widget.product['id'].toString();
      request.fields['room_name'] = nameController.text;
      request.fields['capacity'] = capacityController.text;
      request.fields['location'] = locationController.text;
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
        Navigator.pop(context, true); // ส่งค่า true กลับไปเพื่อบอกหน้า List ให้ Refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("แก้ไขข้อมูลเรียบร้อยแล้ว")),
        );
      } else {
        debugPrint("Server Error: ${data['message']}");
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // กำหนด Path รูปภาพเก่าจาก Server
    String imageUrl = "${baseUrl}images/${widget.product['image']}";

    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไขข้อมูลห้องประชุม")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🖼 ส่วนแสดงรูปภาพ (เก่า หรือ ใหม่ที่เลือก)
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: selectedImage == null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50),
                          )
                        : kIsWeb
                            ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                            : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
                  ),
                ),
              ),
              const Text("แตะที่รูปเพื่อเปลี่ยนรูปใหม่", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "ชื่อห้อง",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "ความจุ (คน)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "สถานที่ / อาคาร",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: updateProduct,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: const Text("บันทึกการแก้ไข", style: TextStyle(fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}