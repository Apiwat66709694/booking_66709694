import 'package:flutter/material.dart';
import 'room_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meeting Room Booking',
      home: RoomList(),   // ✅ หน้าแรกแสดงรายการห้องประชุม
    );

  }

}