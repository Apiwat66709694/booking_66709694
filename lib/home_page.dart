import 'package:flutter/material.dart';
import 'package:flutter_booking_66709694/Login.dart';

// import หน้าอื่น
import 'booking_list.dart';
import 'login_admin.dart';
import 'Login.dart';
// สร้างหน้า HomePage (หน้าแรก)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 AppBar = แถบด้านบนของแอป
      backgroundColor: const Color.fromARGB(255, 94, 37, 252), // ✅ ใส่ตรงนี้
      appBar: AppBar(
        title: const Text('หน้าแรก'),
        backgroundColor: const Color.fromRGBO(100, 162, 255, 1),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0), // ✅ สีไอคอน + ข้อความ
      ),

      // 🔹 Drawer = เมนูด้านข้าง (เลื่อนจากซ้าย)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // เอาช่องว่างด้านบนออก
          children: [
            // 🔸 Header ของ Drawer (ส่วนหัว)
            const UserAccountsDrawerHeader(
              accountName: Text('อภิวัตต์ แก้วมรกตทิพย์'), // ชื่อผู้ใช้
              accountEmail: Text('66709694@chonburi.spu.ac.th'), // อีเมล
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
              leading: const Icon(Icons.event_available),
              title: const Text('ข้อมูลการจอง'),
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
              leading: const Icon(Icons.pages),
              title: const Text('Admin'),
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

      // 🔹 Body = ส่วนเนื้อหาหลักของหน้า
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            //////////////////////////////////////////////////
            // 🖼 รูปจาก assets
            //////////////////////////////////////////////////
            Center(
              child: Image.asset(
                'assets/images/banner1.jpg',
                width: 400,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////
            // 📝 ข้อความ
            //////////////////////////////////////////////////
            const Text(
              'ยินดีต้อนรับเข้าสู่ระบบ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////
            // 🔘 ปุ่ม Login
            //////////////////////////////////////////////////
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                // width: double.infinity,
                // height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('เข้าสู่ระบบ'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
