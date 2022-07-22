import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/port/my_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 243, 245),
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 241, 243, 245),
          surfaceTintColor: Color.fromARGB(255, 241, 243, 245),
          title: Text(
            'Super Share',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
          )),
      body: Container(
      ),
    );
  }
}
