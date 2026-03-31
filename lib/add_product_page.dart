import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AddEquipmentPage extends StatefulWidget {
  const AddEquipmentPage({super.key});

  @override
  State<AddEquipmentPage> createState() => _AddEquipmentPageState();
}

class _AddEquipmentPageState extends State<AddEquipmentPage> {

  ////////////////////////////////////////////////////////////
  // ✅ Controllers (ตรง DB)
  ////////////////////////////////////////////////////////////

  final TextEditingController nameController = TextEditingController();   // eq_name
  final TextEditingController numController = TextEditingController();    // num
  final TextEditingController detailController = TextEditingController(); // detail

  ////////////////////////////////////////////////////////////
  // 🖼 IMAGE
  ////////////////////////////////////////////////////////////

  XFile? selectedImage;

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
  // 💾 SAVE
  ////////////////////////////////////////////////////////////

  Future<void> saveEquipment() async {

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกรูปภาพ")),
      );
      return;
    }

    final url = Uri.parse(
      "http://127.0.0.1/booking_66709694/php_api/insert_room.php",
    );

    var request = http.MultipartRequest('POST', url);

    ////////////////////////////////////////////////////////////
    // ✅ Fields (ต้องตรง PHP)
    ////////////////////////////////////////////////////////////

    request.fields['eq_name'] = nameController.text;
    request.fields['num'] = numController.text;
    request.fields['detail'] = detailController.text;

    ////////////////////////////////////////////////////////////
    // 📤 Upload Image
    ////////////////////////////////////////////////////////////

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

    ////////////////////////////////////////////////////////////
    // 🚀 SEND
    ////////////////////////////////////////////////////////////

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    final data = json.decode(responseData);

    if (data["success"] == true) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เพิ่มอุปกรณ์เรียบร้อย")),
      );

      Navigator.pop(context, true);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${data["error"]}")),
      );
    }
  }

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("เพิ่มอุปกรณ์")),

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
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all()),
                  child: selectedImage == null
                      ? const Center(child: Text("แตะเพื่อเลือกรูป"))
                      : kIsWeb
                          ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                          : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 🏷 NAME
              ////////////////////////////////////////////////////////////

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "ชื่ออุปกรณ์",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 📦 NUM
              ////////////////////////////////////////////////////////////

              TextField(
                controller: numController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "จำนวน",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              ////////////////////////////////////////////////////////////
              // 📝 DETAIL
              ////////////////////////////////////////////////////////////

              TextField(
                controller: detailController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "รายละเอียด",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              ////////////////////////////////////////////////////////////
              // BUTTON
              ////////////////////////////////////////////////////////////

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveEquipment,
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