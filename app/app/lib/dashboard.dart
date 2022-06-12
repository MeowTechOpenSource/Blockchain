import 'dart:convert';

import 'package:app/test.dart';

import 'chain.dart';
import 'history.dart';
import 'shared_variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'wallet.dart';

class ChainData2 {
  String from = '';
  String to = '';
  double amount = 0;
  int nonce = 0;
  double timestamp = 0;
  String hash = '';
  String prevhash = '';
  int id = 0;
}

var dataobs = [];

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int pageIndex = 0;
  final pages = [const Wallet(), const Chain(), const History(),const MyApp()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],
      
      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex,
        onDestinationSelected: (index) => setState(() => pageIndex = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.api_sharp), label: 'Chain'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.bug_report), label: 'Test'),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => http.get(Uri.parse('${SharedVars.blockchainUrl}mine')),
      //   child: const Icon(Icons.wb_twilight_rounded),
      // ),
    );
  }

  
}
