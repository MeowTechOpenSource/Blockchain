import 'chain.dart';
import 'history.dart';
import 'shared_variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'wallet.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({Key? key}) : super(key: key);

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int pageIndex = 0;
  final pages = [const Wallet(), const Chain(), const History()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageIndex,
        showUnselectedLabels: false,
        onTap: (index) => setState(() => pageIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.api_sharp), label: 'Chain'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => http.get(Uri.parse('${SharedVars.blockchainUrl}mine')),
        child: const Icon(Icons.wb_twilight_rounded),
      ),
    );
  }
}
