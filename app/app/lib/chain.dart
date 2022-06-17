// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:app/shared_variables.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class Chain extends StatefulWidget {
  const Chain({Key? key}) : super(key: key);

  @override
  State<Chain> createState() => _ChainState();
}

class _ChainState extends State<Chain> {
  /// Separate lists of blocks, responsible for building the steps:
  List<ChainData> minedData = [];
  List<ChainData> unmineData = [];

  /// Key for stepper, only updates when the lists of blocks changed.
  /// When we use a Stepper, flutter will remember the number of the steps (e.g. 10).
  /// When the steps updated (e.g. length 10 --> 11), flutter will still try to reuse the
  /// previous Stepper with 10 slots only.
  /// So we update this key to force Flutter to create a new Stepper whenever there is change in steps.
  UniqueKey stepperKey = UniqueKey();

  /// Whenever the filter chip is selected, it sets to 0
  int currstep = 0;

  /// Controls the visibilities of mined/unmine blocks
  bool showm = true;
  bool showum = false;

  @override
  void initState() {
    super.initState();
    getChain();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chain')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getChain();
        },
        child: Icon(Icons.refresh),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          getChain();
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
                    Text(
                      "Show: ",
                      style: TextStyle(fontSize: 17),
                    ),
                    FilterChip(
                      pressElevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      selectedColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      selected: showm,
                      label: Text("Mined"),
                      onSelected: (a) {
                        setState(() {
                          showm = a;
                          if (!showm && !showum) {
                            print("Err");
                            showm = true;
                          }
                          currstep = 0;
                          stepperKey = UniqueKey();
                        });

                        getChain();
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    FilterChip(
                        pressElevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        selectedColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        selected: showum,
                        label: Text("Unmined"),
                        onSelected: (a) {
                          setState(() {
                            showum = a;
                            currstep = 0;
                            stepperKey = UniqueKey();

                            if (!showm && !showum) {
                              showm = true;
                            }
                          });
                          getChain();
                        }),
                  ],
                ),
              ),
              Stepper(
                key: stepperKey,
                physics: ClampingScrollPhysics(),
                currentStep: currstep,
                onStepTapped: (index) => setState(() => currstep = index),
                controlsBuilder: (_, __) => Container(),
                steps: buildSteps(showMined: showm, showUnmine: showum),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getChain() {
    var url = Uri.parse('${SharedVars.blockchainUrl}chain');

    http.get(url).then((response) {
      int am = 0;

      /// Update the lists of mined blocks
      if (response.statusCode == 200) {
        List<ChainData> dataobjs = [];
        var data = jsonDecode(response.body);
        if (showm) {
          for (var d in data["chain"]) {
            ChainData c = ChainData();

            c.from = d["transaction"]["from"];
            c.to = d["transaction"]["to"];
            if (c.from == "_") c.from = "System";
            if (c.to == "_") c.to = "System";

            c.nonce = d["nonce"];
            c.hash = d["hash"];
            c.prevhash = d["prev_hash"];
            c.timestamp = double.parse(d["timestamp"].toString());
            c.amount = double.parse(d["transaction"]["amount"].toString());
            am += 1;
            c.id = am;
            dataobjs.add(c);
          }

          setState(() {
            if (minedData.length != dataobjs.length) {
              stepperKey = UniqueKey();
            }
            minedData = dataobjs;
          });
        }
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(response.statusCode.toString()),
                content: Text(response.body)));
      }

      /// Update the lists of unmine blocks
      if (showum) {
        var url = Uri.parse('${SharedVars.blockchainUrl}unmined_blocks');
        http.get(url).then((response) {
          if (response.statusCode == 200) {
            List<ChainData> dataobjs = [];

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

            setState(() {
              if (unmineData.length != dataobjs.length) {
                stepperKey = UniqueKey();
              }
              unmineData = dataobjs;
            });
          } else {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                    title: Text(response.statusCode.toString()),
                    content: Text(response.body)));
          }
        });
      }
    });
  }

  List<Step> buildSteps({required bool showMined, required bool showUnmine}) {
    List<ChainData> blocks = [];
    if (showMined) {
      blocks.addAll(minedData);
    }
    if (showUnmine) {
      blocks.addAll(unmineData);
    }

    List<Step> steps = [];
    if (blocks.isEmpty) {
      /// Add a dummy step:
      steps.add(Step(
        title: Text("Transaction #1"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Block Details",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text("Hash: "),
            Text("Nonce: "),
            Text("Timestamp: "),
            Divider(),
            Text(
              "Transaction Details",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text("Amount: \$ 0"),
            Text("From: "),
            Text("To: "),
          ],
        ),
      ));
    } else {
      /// Create steps from all ChainData
      for (var b in blocks) {
        steps.add(Step(
          title: Text("${b.title} #${b.id}"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Block Details",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text("Hash: ${b.hash}"),
              Text("Nonce: ${b.nonce}"),
              Text("Timestamp: ${b.timestamp}"),
              Divider(),
              Text(
                "Transaction Details",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text("Amount: \$${b.amount}"),
              Text("From: ${b.from}"),
              Text("To: ${b.to}")
            ],
          ),
        ));
      }
    }
    return steps;
  }
}
