import 'package:flutter/material.dart';
import 'package:flutter_booking_66709694/room_list.dart';
import 'Home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'equipment',
      home: RoomList(name: '',),   // ✅ หน้าแรกแสดงรายการห้องประชุม
    );

  }

}