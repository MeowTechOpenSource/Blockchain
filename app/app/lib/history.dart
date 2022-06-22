import 'dart:convert';

import 'package:flutter/material.dart';
import 'model/block.dart';
import 'shared_variables.dart';
import 'package:http/http.dart' as http;

var dataobs = [];

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("History")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getChain();
        },
        child: Icon(Icons.refresh),
      ),
      body: ListView.builder(
        itemCount: dataobs.length,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    DateTime.fromMicrosecondsSinceEpoch(
                            (dataobs[index].timestamp * 1000000).round())
                        .toString(),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Divider(),
                  Text(
                    "Transaction Details",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text("Amount: \$" + dataobs[index].amount.toString()),
                  Text("From: " + dataobs[index].from.toString()),
                  Text("To: " + dataobs[index].to.toString())
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void getChain() {
    var dataobjs2 = [];
    var url = Uri.parse('${SharedVars.blockchainUrl}chain');
    http.get(url).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        for (var d in data["chain"]) {
          Block c = Block();
          c.from = d["transaction"]["from"];
          c.to = d["transaction"]["to"];
          if (c.from == "_") {
            c.from = "System";
          }
          if (c.to == "_") {
            c.to = "System";
          }
          c.nonce = d["nonce"];
          c.hash = d["hash"];
          c.prevHash = d["prev_hash"];
          c.timestamp = double.parse(d["timestamp"].toString());
          c.amount = double.parse(d["transaction"]["amount"].toString());
          if (c.from == SharedVars.username || c.to == SharedVars.username) {
            dataobjs2.add(c);
          }
        }
        dataobs = dataobjs2;
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(response.statusCode.toString()),
                content: Text(response.body)));
      }
    });
    setState(() {});
  }
}
