import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // Add this import

import '../../constant/constant.dart';
import '../../controller/user_controller.dart';
import '../../global/global.dart';
import 'Board/ChoicePage.dart';
import 'BoardDetail.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> books = []; // List to hold fetched books

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('${Global.baseUrl}/home/bookPost/'),
      headers: {
        'Authorization': 'Bearer ${AuthService.accessToken}'
      }, // Add your bearer token
    );

    if (response.statusCode == 200) {
      String decodedResponse = utf8.decode(response.bodyBytes);
      setState(() {
        books = json.decode(decodedResponse);
      });
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
        centerTitle: false,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_active)),
        ],
      ),
      body: ListView.builder(
        itemCount: books.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(books[index]['title']),
            subtitle: Text(books[index]['writer']),
            leading: Image.network(
              books[index]['state_image'],
              width: 70, // Adjust the width as needed
              height: 120, // Adjust the height as needed
              fit: BoxFit.cover,
            ),
            onTap: () {
              Get.to(() =>
                  BoardDetail(book: books[index])); // Pass the book details
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => ChoicePage());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
