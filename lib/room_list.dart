import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'booking_page.dart';
import 'booking_list.dart';
import 'login.dart';

//////////////////////////////////////////////////////////////
// API URL
//////////////////////////////////////////////////////////////

const String baseUrl = "http://localhost/flutter_booking_66709694/php_api/";

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
  List rooms = [];
  List filteredRooms = [];

  TextEditingController searchController = TextEditingController();

  ////////////////////////////////////////////////////////////
  // INIT
  ////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  ////////////////////////////////////////////////////////////
  // FETCH ROOMS
  ////////////////////////////////////////////////////////////

  Future<void> fetchRooms() async {
    final response =
        await http.get(Uri.parse("${baseUrl}get_rooms.php"));

    if (response.statusCode == 200) {
      setState(() {
        rooms = json.decode(response.body);
        filteredRooms = rooms;
      });
    }
  }

  ////////////////////////////////////////////////////////////
  // SEARCH ROOM
  ////////////////////////////////////////////////////////////

  void searchRoom(String keyword) {
    final results = rooms.where((room) {
      final name = room['room_name'].toString().toLowerCase();
      return name.contains(keyword.toLowerCase());
    }).toList();

    setState(() {
      filteredRooms = results;
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
                  builder: (_) => const LoginPage(),
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

      appBar: AppBar(
        title: Text("Meeting Room (${widget.name})"),
        actions: [
          //////////////////////////////////////////////////////
          // ดูรายการจอง
          //////////////////////////////////////////////////////
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: "ดูการจองทั้งหมด",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BookingList(),
                ),
              );
            },
          ),

          //////////////////////////////////////////////////////
          // LOGOUT
          //////////////////////////////////////////////////////
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "ออกจากระบบ",
            onPressed: logout,
          ),
        ],
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
                hintText: "ค้นหาห้องประชุม...",
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
            child: filteredRooms.isEmpty
                ? const Center(child: Text("ไม่พบข้อมูลห้อง"))
                : ListView.builder(
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];

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
                            room['room_name'] ?? "",
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
                                  "Capacity: ${room['capacity']} คน"),
                              Text(
                                  "Location: ${room['location']}"),
                            ],
                          ),

                          ////////////////////////////////////////////////////
                          // ACTION BUTTON
                          ////////////////////////////////////////////////////
                          trailing: Wrap(
                            direction: Axis.vertical,
                            spacing: 2,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(70, 28),
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 2),
                                ),
                                child: const Text("จอง"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BookingPage(room: room),
                                    ),
                                  );
                                },
                              ),

                              IconButton(
                                icon: const Icon(Icons.event_note,
                                    color: Colors.orange),
                                tooltip: "ดูข้อมูลการจอง",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookingList(
                                        roomId: room['id'],
                                      ),
                                    ),
                                  );
                                },
                              ),
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