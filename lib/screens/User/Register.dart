import 'dart:convert';

import 'package:book/controller/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;

import '../../global/global.dart';
import 'EmailCheck.dart';
import 'Login.dart';
// import 'package:http/http.dart' as http;

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  //파이어스토어관련  -------
  final _authentication = FirebaseAuth.instance;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  //파이어 끝  -------

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _registerUser() async {
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;

    // Create a map with the user credentials
    Map<String, String> credentials = {
      'name': name,
      'email': email,
      'password': password,
    };

    // Convert the credentials map to a JSON string
    String jsonData = jsonEncode(credentials);

    // Set the request headers
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // Send the POST request
    final response = await http.post(
      Uri.parse('${Global.baseUrl}/account/register/'),
      headers: headers,
      body: jsonData,
    );
    print(response.statusCode);
    // Check the response
    if (response.statusCode == 200) {
      // Register successful

      //firebase -------
      final newUser = await _authentication.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = _authentication.currentUser;

      if (user != null) {
        // 사용자 UID로 Firestore에 데이터 저장
        users.doc(user.uid).set({
          'name': name,
          'email': email,
        });
      }

      //firebase 끝 -------

      String decodedResponse = utf8.decode(response.bodyBytes);
      print('Register successful! Response: ${decodedResponse}');
      await AuthService.login(decodedResponse);
      Get.offAll(() => EmailCheck());
      // You can add navigation logic here to redirect to another page after successful login
    } else {
      // Login failed
      String decodedResponse = utf8.decode(response.bodyBytes);
      print('Register failed. Error: $decodedResponse');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
