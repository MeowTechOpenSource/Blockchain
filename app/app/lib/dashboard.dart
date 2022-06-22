import 'dart:convert';

import 'package:app/port/my_button.dart';
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
  final pages = [const Wallet(), const Chain(), const History(), const MyApp()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],

      bottomNavigationBar: bottomNavPhone(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => http.get(Uri.parse('${SharedVars.blockchainUrl}mine')),
      //   child: const Icon(Icons.wb_twilight_rounded),
      // ),
    );
  }

  buildPhoneNavBtn(int buttonId, IconData iconData, String label) {
    //Build Phone Bottom Nav Buttons
    return MyButton(
        onPressed: () {
          pageIndex = buttonId;
          setState(() {});
          //Call animation to restart
          //doanimation(buttonId, prev);
        },
        backgroundColor: Colors.transparent,
        borderRadius: 7,
        height: 57,
        textColor: buttonId == pageIndex
            ? Color.fromARGB(255, 10, 89, 247)
            : Color.fromARGB(255, 144, 145, 147),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            iconData,
            color: buttonId == pageIndex
                ? Color.fromARGB(255, 10, 89, 247)
                : Color.fromARGB(255, 144, 145, 147),
          ),
          //SizedBox(width: 5),
          Text(label)
        ]));
  }

  bottomNavPhone() {
    return Container(
      width: double.infinity,
      color: Color.fromARGB(255, 241, 243, 245),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            //NavBar Item
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Row(
                children: [
                  Expanded(
                    child: buildPhoneNavBtn(
                      0,
                      Icons.account_balance_wallet,
                      'Wallet',
                    ),
                  ),
                  Expanded(
                    child: buildPhoneNavBtn(
                      1,
                      Icons.api_sharp,
                      'Chain',
                    ),
                  ),
                  Expanded(
                    child: buildPhoneNavBtn(2, Icons.history, 'History'),
                  ),
                  Expanded(
                    child: buildPhoneNavBtn(3, Icons.bug_report, 'Debug'),
                  )
                ],
              ),
            )
          ]),
    );
  }
}
