import 'dart:convert';
import 'package:expandable/expandable.dart';
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
          getChain();
        },
        child: Icon(Icons.refresh),
      ),
      body: ListView.builder(
        itemCount: dataobs.length,
        itemBuilder: (context, index) {
          String me = (dataobs[index].from.toString() == SharedVars.username) ? "-" : "";
          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: ExpandableNotifier(
              child: ScrollOnExpand(
                scrollOnExpand: true,
                scrollOnCollapse: false,
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
                  elevation: 0,
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: ExpandablePanel(
                      header: Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                        child: Text(
                          DateTime.fromMicrosecondsSinceEpoch(
                                  (dataobs[index].timestamp * 1000000).round())
                              .toString(),
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      collapsed: Padding(
                        padding: const EdgeInsets.fromLTRB(3, 0, 16, 0),
                        child: Text("MTC \$"+ me +dataobs[index].amount.toString(),style: TextStyle(
                          color: (me == "-") ? Colors.red : Colors.black,
                        ),),
                      ),
                      expanded: Padding(
                        padding: const EdgeInsets.fromLTRB(3, 0, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Amount: \$" + dataobs[index].amount.toString()),
                            Text("From: " + dataobs[index].from.toString()),
                            Text("To: " + dataobs[index].to.toString())
                          ],
                        ),
                      ),
                      theme: ExpandableThemeData(
                          headerAlignment: ExpandablePanelHeaderAlignment.center,
                          tapBodyToCollapse: true,
                          tapHeaderToExpand: true,
                          inkWellBorderRadius:
                              BorderRadius.all(Radius.circular(13))),
                    ),
                  ),
                ),
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
