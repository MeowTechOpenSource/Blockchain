import 'dart:convert';
import 'package:harmonyos/harmonyos.dart';

import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'shared_variables.dart';

double balance = 0;
bool hidebal = false;

class Wallet extends StatefulWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  @override
  void initState() {
    super.initState();
    var url = Uri.parse('${SharedVars.blockchainUrl}get_balance');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode(
        {'username': SharedVars.username, 'password': SharedVars.password});
    http.post(url, headers: headers, body: body).then((response) {
      if (response.statusCode == 200) {
        balance = jsonDecode(response.body)['balance'];
        setState(() {});
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(response.statusCode.toString()),
                content: Text(response.body)));
      }
    });
  }

  Color bg =
      Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  Widget build(BuildContext context) {
    return Scaffold(
        // drawer: Drawer(
        //   child: ListView(
        //     // Important: Remove any padding from the ListView.
        //     padding: EdgeInsets.zero,
        //     children: [
        //       DrawerHeader(
        //         decoration: BoxDecoration(
        //           image: DecorationImage(
        //               image: NetworkImage(
        //                   "https://www.blueinnotechnology.com/wp-content/uploads/2022/03/Blueinno_logo_2020_v2.png")),
        //           color: Theme.of(context).colorScheme.primaryContainer,
        //         ),
        //         child: Align(
        //             alignment: Alignment.bottomCenter,
        //             child: Text('Meow Tech Coin')),
        //       ),
        //       ListTile(
        //         style: ListTileStyle.drawer,
        //         title: const Text('Item 1'),
        //         onTap: () {
        //           // Update the state of the app.
        //           // ...
        //         },
        //       ),
        //       ListTile(
        //         style: ListTileStyle.drawer,
        //         title: const Text('Item 2'),
        //         onTap: () {
        //           // Update the state of the app.
        //           // ...
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            var url = Uri.parse('${SharedVars.blockchainUrl}get_balance');
            var headers = {'Content-Type': 'application/json'};
            var body = jsonEncode({
              'username': SharedVars.username,
              'password': SharedVars.password
            });
            http.post(url, headers: headers, body: body).then((response) {
              if (response.statusCode == 200) {
                balance = jsonDecode(response.body)['balance'];
                setState(() {});
              } else {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                        title: Text(response.statusCode.toString()),
                        content: Text(response.body)));
              }
            });
          },
          child: Icon(Icons.refresh),
        ),
        appBar: AppBar(
          title: Text(
            'Wallet',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Color.fromARGB(255, 241, 243, 245),
          actions: [
            MaterialButton(
              shape: CircleBorder(),
              onPressed: () {
                showMenu<String>(
                  context: context,
                  constraints:
                      const BoxConstraints(minHeight: 50, minWidth: 150),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  position: RelativeRect.fromLTRB(25.0, 25.0, 0.0,
                      0.0), //position where you want to show the menu on screen
                  items: [
                    PopupMenuItem<String>(
                        child: const Text('Logout'), value: '1'),
                  ],

                  elevation: 20,
                  // color: Theme.of(context).colorScheme.surfaceVariant,
                ).then((value) {
                  if (value == null) {
                  } else {
                    SharedVars.username = "";
                    SharedVars.password = "";
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      SharedVars.username[0].toUpperCase(),
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            )
          ],
        ),
        body: Container(
          color: Color.fromRGBO(241, 243, 245, 1),
          child: Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        width: 500,
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 243, 77, 80),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25))),
                        child: Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //
                            Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                ),
                                HMButton(
                                  textColor: Colors.white,
                                  height: 100,
                                  width: 100,
                                  onPressed: () {
                                    double? amount;
                                    String? user;
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                            title: Text("Transfer"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    if (amount == null ||
                                                        user == "") {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                              backgroundColor: Theme
                                                                      .of(
                                                                          context)
                                                                  .colorScheme
                                                                  .surfaceVariant,
                                                              title:
                                                                  Text("Error"),
                                                              content: Text(
                                                                  "Empty username or amount")));
                                                    } else if (user ==
                                                        SharedVars.username) {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                              backgroundColor: Theme
                                                                      .of(
                                                                          context)
                                                                  .colorScheme
                                                                  .surfaceVariant,
                                                              title:
                                                                  Text("Error"),
                                                              content: Text(
                                                                  "The target of the transfer must not be you.")));
                                                    } else {
                                                      print("go");
                                                      showDialog(
                                                          barrierDismissible:
                                                              false,
                                                          context: context,
                                                          builder: (_) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  "Transfer"),
                                                              backgroundColor: Theme
                                                                      .of(context)
                                                                  .colorScheme
                                                                  .surfaceVariant,
                                                              content: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize.min,
                                                                    children: [
                                                                      CircularProgressIndicator(),
                                                                      Text(
                                                                          "Commiting Action...")
                                                                    ]),
                                                              ),
                                                            );
                                                          });

                                                      var url = Uri.parse(
                                                          '${SharedVars.blockchainUrl}new_transaction');
                                                      var headers = {
                                                        'Content-Type':
                                                            'application/json'
                                                      };
                                                      var body = jsonEncode({
                                                        'from':
                                                            SharedVars.username,
                                                        "to": user,
                                                        "amount": amount,
                                                        'password':
                                                            SharedVars.password
                                                      });

                                                      http
                                                          .post(url,
                                                              headers: headers,
                                                              body: body)
                                                          .then((response) {
                                                        Navigator.of(context)
                                                            .pop();
                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          Navigator.of(context)
                                                              .pop();
                                                        } else {
                                                          showDialog(
                                                              context: context,
                                                              builder: (context) => AlertDialog(
                                                                  backgroundColor: Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .surfaceVariant,
                                                                  title: Text(response
                                                                      .statusCode
                                                                      .toString()),
                                                                  content: Text(
                                                                      jsonDecode(
                                                                          response
                                                                              .body)["value"])));
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Text("Transfer"))
                                            ],
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  onChanged: (value) {
                                                    if (value == "") {
                                                      amount = null;
                                                    } else {
                                                      if (value
                                                          .startsWith(".")) {
                                                        value = "0" + value;
                                                      }
                                                      if (value == ".") {
                                                        value = "0";
                                                      }
                                                      amount =
                                                          double.parse(value);
                                                    }
                                                  },
                                                  keyboardType: TextInputType
                                                      .numberWithOptions(
                                                          decimal: true,
                                                          signed: false),
                                                  inputFormatters: <
                                                      TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(
                                                            r"(^\-?\d*\.?\d*)")),
                                                  ],
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText: 'Amount'),
                                                ),
                                                TextField(
                                                  onChanged: (value) =>
                                                      user = value,
                                                  decoration:
                                                      const InputDecoration(
                                                          labelText: 'User'),
                                                )
                                              ],
                                            )));
                                  },
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.sync,
                                          color: Colors.white,
                                        ),
                                        Text("Transfer")
                                      ]),
                                ),
                              ],
                            ),
                            // Align(
                            //     alignment: Alignment.centerRight,
                            //     child: Padding(
                            //       padding:
                            //           const EdgeInsets.fromLTRB(0, 0, 20, 10),
                            //       child: TextButton(
                            //           onPressed: () {}, child: Text("More  >")),
                            //     ))
                          ],
                        )),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        "Remainder",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Text(
                            hidebal
                                ? "MTC\$${balance.toString().replaceAll(RegExp("[0-9]"), "•")} (HKD\$0.0)"
                                : "MTC\$${balance.toString()} (HKD\$${(balance * 0.0001).toString()})",
                            style: TextStyle(fontSize: 18),
                          ),
                          Spacer(),
                          HMIconButton(
                              onPressed: () {
                                hidebal = !hidebal;
                                setState(() {});
                              },
                              icon: Icon(hidebal
                                  ? Icons.visibility
                                  : Icons.visibility_off))
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
