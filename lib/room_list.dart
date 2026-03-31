import 'package:flutter/material.dart';
import 'package:flutter_booking_66709694/login_admin.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_page.dart';
import 'booking_list.dart';
import 'home_page.dart';
//////////////////////////////////////////////////////////////
// API URL
//////////////////////////////////////////////////////////////

const String baseUrl = "http://localhost/booking_66709694/php_api/";

//////////////////////////////////////////////////////////////
// ROOM LIST PAGE
//////////////////////////////////////////////////////////////

class RoomList extends StatefulWidget {
  final String name;

  const RoomList({super.key, required this.name});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  List equipment = [];
  List filteredequipment = [];

  TextEditingController searchController = TextEditingController();

  ////////////////////////////////////////////////////////////
  // INIT
  ////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    fetchequipment();
  }

  ////////////////////////////////////////////////////////////
  // FETCH ROOMS
  ////////////////////////////////////////////////////////////

  Future<void> fetchequipment() async {
    final response =
        await http.get(Uri.parse("${baseUrl}get_rooms.php"));

    if (response.statusCode == 200) {
      setState(() {
       equipment = json.decode(response.body);
        filteredequipment = equipment;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  // SEARCH ROOM
  ////////////////////////////////////////////////////////////

  void searchRoom(String keyword) {
    final results = equipment.where((room) {
      final name = room['room_name'].toString().toLowerCase();
      return name.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredequipment = results;
    });
  }

  ////////////////////////////////////////////////////////////
  // LOGOUT FUNCTION
  ////////////////////////////////////////////////////////////

  void logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("ยืนยัน"),
        content: const Text("ต้องการออกจากระบบหรือไม่?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomePage(),
                ),
                (route) => false,
              );
            },
            child: const Text("ออกจากระบบ"),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      ////////////////////////////////////////////////////////
      // APPBAR
      ////////////////////////////////////////////////////////

      backgroundColor: const Color.fromARGB(255, 255, 84, 232), // ✅ ใส่ตรงนี้
      appBar: AppBar(
        title: const Text('หน้าแรก'),
        backgroundColor: const Color.fromARGB(255, 255, 217, 244),
        foregroundColor: const Color.fromARGB(255, 252, 110, 110), // ✅ สีไอคอน + ข้อความ
      ),

      // 🔹 Drawer = เมนูด้านข้าง (เลื่อนจากซ้าย)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // เอาช่องว่างด้านบนออก
          children: [
            // 🔸 Header ของ Drawer (ส่วนหัว)
            const UserAccountsDrawerHeader(
              accountName: Text('ใส่ชื่อนักศึกษา'), // ชื่อผู้ใช้
              accountEmail: Text('ใส่รหัสนักศึกษา'), // อีเมล
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person), // ไอคอนโปรไฟล์
              ),
            ),

            // 🔸 เมนู: หน้าแรก
            ListTile(
              leading: const Icon(Icons.home), // ไอคอน
              title: const Text('หน้าแรก'), // ข้อความเมนู
              onTap: () {
                Navigator.pop(context); // ปิด Drawer
              },
            ),

            // 🔸 เมนู: ไปหน้า Page 1
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('อุปกรณ์'),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer ก่อน

                // 🔹 เปิดหน้าใหม่ (Page1)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingList()),
                );
              },
            ),

            // 🔸 เมนู: ไปหน้า Page 2
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('เข้าสู่ระบบ'),
              onTap: () {
                Navigator.pop(context); // ปิด Drawer ก่อน

                // 🔹 เปิดหน้าใหม่ (Page2)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginAdmin()),
                );
              },
            ),
            
          ],
        ),
      ),

      ////////////////////////////////////////////////////////
      // BODY
      ////////////////////////////////////////////////////////

      body: Column(
        children: [
          //////////////////////////////////////////////////////
          // SEARCH BOX
          //////////////////////////////////////////////////////
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "ค้นหาสินค้า...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: searchRoom,
            ),
          ),

          //////////////////////////////////////////////////////
          // ROOM LIST
          //////////////////////////////////////////////////////
          Expanded(
            child: filteredequipment.isEmpty
                ? const Center(child: Text("ไม่พบข้อมูลสินค้า"))
                : ListView.builder(
                    itemCount: filteredequipment.length,
                    itemBuilder: (context, index) {
                      final room = filteredequipment[index];

                      String imageUrl =
                          "${baseUrl}images/${room['image'] ?? ''}";

                      return Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 3,
                        child: ListTile(
                          isThreeLine: true,

                          ////////////////////////////////////////////////////
                          // IMAGE
                          ////////////////////////////////////////////////////
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.meeting_room),
                            ),
                          ),

                          ////////////////////////////////////////////////////
                          // TITLE
                          ////////////////////////////////////////////////////
                          title: Text(
                            room['eq_name'] ?? "",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),

                          ////////////////////////////////////////////////////
                          // SUBTITLE
                          ////////////////////////////////////////////////////
                          subtitle: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "จำนวน: ${room['num']} ชิ้น"),
                              Text(
                                  "รายระเอียด: ${room['detail']}"),
                            ],
                          ),

                          ////////////////////////////////////////////////////
                          // ACTION BUTTON
                          ////////////////////////////////////////////////////
                          trailing: Wrap(
                            direction: Axis.vertical,
                            spacing: 2,
                            children: [
                             

                              
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}