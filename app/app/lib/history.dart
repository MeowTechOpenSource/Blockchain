import 'dart:convert';

import 'package:flutter/material.dart';
import 'shared_variables.dart';
import 'package:http/http.dart' as http;

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

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Color.fromARGB(255, 241, 243, 245),
        surfaceTintColor: Color.fromARGB(255, 241, 243, 245),
      ),
      backgroundColor: Color.fromARGB(255, 241, 243, 245),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GetChain();
        },
        child: Icon(Icons.refresh),
      ),
      body: ListView.builder(
        itemCount: dataobs.length,
        itemBuilder: (context, index) {
          return Container(
            child: Card(
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
            ),
          );
        },
      ),
    );
  }

  void GetChain() {
    var dataobjs2 = [];
    var url = Uri.parse('${SharedVars.blockchainUrl}chain');
    http.get(url).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        for (var d in data["chain"]) {
          ChainData2 c = ChainData2();
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
          c.prevhash = d["prev_hash"];
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
