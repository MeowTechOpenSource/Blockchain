import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dashboard.dart';
import 'shared_variables.dart';

main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      theme: ThemeData(useMaterial3: true,colorSchemeSeed: Colors.blue),
    ));

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String username = '';
  String password = '';

  String logoUrl =
      'https://www.blueinnotechnology.com/wp-content/uploads/2022/03/Blueinno_logo_2020_v2.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Logo image:
              Image.network(logoUrl),

              /// Username field:
              TextField(
                decoration: const InputDecoration(labelText: 'Username'),
                onChanged: (String value) => username = value,
              ),

              /// Password field:
              TextField(
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (String value) => password = value,
                obscureText: true,
              ),

              /// Sign-in/up button:
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => signInUp(endpoint: 'create_user'),
                    child: const Text('Sign up'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => signInUp(endpoint: 'login'),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signInUp({required String endpoint}) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);

    var url = Uri.parse('${SharedVars.blockchainUrl}$endpoint');
    var headers = {'Content-Type': 'application/json'};
    var body =
        jsonEncode({'username': username, 'password': digest.toString()});

    http.post(url, headers: headers, body: body).then((response) {
      if (response.statusCode == 200) {
        SharedVars.username = username;
        SharedVars.password = digest.toString();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashBoard()),
        );
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(response.statusCode.toString()),
                content: Text(response.body)));
      }
    });
  }
}
