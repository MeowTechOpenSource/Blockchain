import 'dart:convert';
import 'dart:math';

import 'package:app/shared_variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

var currstep = 0;
bool showm = true;
bool showum = false;
int something = 1;

class ChainData {
  String from = '';
  String to = '';
  double amount = 0;
  int nonce = 0;
  double timestamp = 0;
  String hash = '';
  String prevhash = '';
  String title = 'Transaction';
  int id = 0;
}

var dataobs = [ChainData()];

class Chain extends StatefulWidget {
  const Chain({Key? key}) : super(key: key);

  @override
  State<Chain> createState() => _ChainState();
}

class _ChainState extends State<Chain> {
  @override
  Widget build(BuildContext context) {
    something += 1;
    void initState() {
      super.initState();
      GetChain();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Chain'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GetChain();
        },
        child: Icon(Icons.refresh),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          GetChain();
        },
        child: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Show: ",style: TextStyle(fontSize: 17),),
                    FilterChip(
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      selected: showm,
                      label: Text("Mined"),
                      onSelected: (a) {
                        showm = a;
                        if (!showm && !showum) {
                          print("Err");
                          showm = true;
                        }
                        currstep = 0;
                        dataobs = [ChainData()];
                        setState(() {});
                        GetChain();
                        setState(() {});
                      },
                    ),
                    SizedBox(width: 10,),
                    FilterChip(
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                        selected: showum,
                        label: Text("Unmined"),
                        onSelected: (a) {
                          showum = a;
                          currstep = 0;
                          dataobs = [ChainData()];
                          if (!showm && !showum) {
                            showm = true;
                          }
                          setState(() {});
                          GetChain();
                          setState(() {});
                        }),
                  ],
                ),
              ),
              Stepper(
                  key: Key("key-" + something.toString()),
                  currentStep: currstep,
                  onStepTapped: (index) {
                    print(index);
                    currstep = index;
                    setState(() {});
                  },
                  controlsBuilder: (context, details) {
                    return Container();
                  },
                  steps: [
                    for (var n in dataobs)
                      Step(
                        title: Text("${n.title} #" + n.id.toString()),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Block Details",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text("Hash: " + n.hash),
                            Text("Nonce: " + n.nonce.toString()),
                            Text("Timestamp: " + n.timestamp.toString()),
                            Divider(),
                            Text(
                              "Transaction Details",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text("Amount: \$" + n.amount.toString()),
                            Text("From: " + n.from.toString()),
                            Text("To: " + n.to.toString())
                          ],
                        ),
                      )
                  ])
            ],
          ),
        ),
      ),
    );
  }

  void GetChain() {
    List<ChainData> dataobjs = [];
    int am = 0;
    if (true) {
      var url = Uri.parse('${SharedVars.blockchainUrl}chain');
      http.get(url).then((response) {
        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);

          for (var d in data["chain"]) {
            ChainData c = ChainData();
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
            am += 1;
            c.id = am;
            dataobjs.add(c);
          }
          dataobs = dataobjs;
          if (!showm) {
            dataobs = [];
            dataobjs = [];
          }
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                  title: Text(response.statusCode.toString()),
                  content: Text(response.body)));
        }
        if (showum) {
          var url = Uri.parse('${SharedVars.blockchainUrl}unmined_chain');
          http.get(url).then((response) {
            if (response.statusCode == 200) {
              var data = jsonDecode(response.body);
              for (var d in data["unmined blocks"]) {
                ChainData c = ChainData();
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
                c.title = "Unmined Block";
                am += 1;
                c.id = am;
                dataobjs.add(c);
              }
              dataobs = dataobjs;
            } else {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                      title: Text(response.statusCode.toString()),
                      content: Text(response.body)));
            }
            if (dataobs.length == 0) {
              dataobs = [ChainData()];
            }

            setState(() {});
          });
          if (!showum) {
            if (dataobs.length == 0) {
              dataobs = [ChainData()];
            }
            setState(() {});
          }
        }
      });
    }
  }
}
