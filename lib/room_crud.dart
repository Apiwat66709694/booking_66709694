import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'add_product_page.dart';
import 'edit_product_page.dart';
import 'home_page.dart';

//////////////////////////////////////////////////////////////
// ✅ CONFIG
//////////////////////////////////////////////////////////////

const String baseUrl =
    "http://127.0.0.1/booking_66709694/php_api/";

//////////////////////////////////////////////////////////////
// ✅ EQUIPMENT LIST PAGE
//////////////////////////////////////////////////////////////

class RoomPage extends StatefulWidget {
  final String name;
  const RoomPage({super.key, required this.name});

  @override
  State<RoomPage> createState() => _ProductListState();
}

class _ProductListState extends State<RoomPage> {

  List products = [];
  List filteredProducts = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  ////////////////////////////////////////////////////////////
  // ✅ FETCH DATA
  ////////////////////////////////////////////////////////////

  Future<void> fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse("${baseUrl}get_rooms.php"));

      if (response.statusCode == 200) {
        setState(() {
          products = json.decode(response.body);
          filteredProducts = products;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ SEARCH
  ////////////////////////////////////////////////////////////

  void filterProducts(String query) {
    setState(() {
      filteredProducts = products.where((product) {
        final name = product['eq_name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  ////////////////////////////////////////////////////////////
  // ✅ DELETE
  ////////////////////////////////////////////////////////////

  Future<void> deleteProduct(int id) async {
    final response = await http.get(
      Uri.parse("${baseUrl}delete_product.php?id=$id"),
    );

    final data = json.decode(response.body);

    if (data["success"] == true) {
      fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ลบอุปกรณ์เรียบร้อย")),
      );
    }
  }

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Equipment List'),
        actions: [

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: (){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const HomePage(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [

          //////////////////////////////////////////////////////
          // 🔍 SEARCH
          //////////////////////////////////////////////////////

          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search equipment',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterProducts,
            ),
          ),

          //////////////////////////////////////////////////////
          // 📦 LIST
          //////////////////////////////////////////////////////

          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("ไม่มีข้อมูล"))
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {

                      final product = filteredProducts[index];

                      String imageUrl =
                          "${baseUrl}images/${product['image'] ?? ''}";

                      return Card(
                        child: ListTile(

                          //////////////////////////////////////////////////
                          // 🖼 IMAGE
                          //////////////////////////////////////////////////

                          leading: SizedBox(
                            width: 70,
                            height: 70,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),

                          //////////////////////////////////////////////////
                          // 🏷 NAME
                          //////////////////////////////////////////////////

                          title: Text(product['eq_name'] ?? ''),

                          //////////////////////////////////////////////////
                          // 📝 DETAIL + NUM
                          //////////////////////////////////////////////////

                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("รายละเอียด: ${product['detail']}"),
                              Text("จำนวน: ${product['num']}"),
                            ],
                          ),

                          //////////////////////////////////////////////////
                          // ⚙️ MENU
                          //////////////////////////////////////////////////

                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProductPage(product: product),
                                  ),
                                ).then((value) => fetchProducts());
                              } else if (value == 'delete') {
                                deleteProduct(
                                    int.parse(product['id'].toString()));
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('แก้ไข'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('ลบ'),
                              ),
                            ],
                          ),

                          //////////////////////////////////////////////////
                          // 👉 DETAIL PAGE
                          //////////////////////////////////////////////////

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetail(product: product),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      ////////////////////////////////////////////////////////
      // ➕ ADD BUTTON
      ////////////////////////////////////////////////////////

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEquipmentPage(),
            ),
          ).then((value) => fetchProducts());
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ DETAIL PAGE
//////////////////////////////////////////////////////////////

class ProductDetail extends StatelessWidget {
  final dynamic product;

  const ProductDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {

    String imageUrl =
        "${baseUrl}images/${product['image'] ?? ''}";

    return Scaffold(
      appBar: AppBar(
        title: Text(product['eq_name'] ?? 'Detail'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Center(
              child: Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              product['eq_name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text("รายละเอียด: ${product['detail']}"),

            const SizedBox(height: 10),

            Text("จำนวนคงเหลือ: ${product['num']}"),
          ],
        ),
      ),
    );
  }
}