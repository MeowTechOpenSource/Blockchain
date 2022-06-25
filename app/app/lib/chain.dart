// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:app/blockchain_api.dart';
import 'package:app/shared_variables.dart';
import 'package:image_sequence_animator/image_sequence_animator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'model/block.dart';

class Chain extends StatefulWidget {
  const Chain({Key? key}) : super(key: key);

  @override
  State<Chain> createState() => _ChainState();
}

class _ChainState extends State<Chain> {
  /// Indicator to update stepperKey below
  int prevChainLength = 0;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 243, 245),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 241, 243, 245),
        surfaceTintColor: Color.fromARGB(255, 241, 243, 245),
        title: Text(
          'Chain',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: Container(
          color: Color.fromARGB(255, 241, 243, 245),
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
                      showCheckmark: false,
                      pressElevation: 0,
                      selectedColor:
                          Color.fromARGB(255, 243, 77, 80).withOpacity(0.4),
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
                      },
                    ),
                    SizedBox(width: 10),
                    FilterChip(
                        pressElevation: 0,
                        showCheckmark: false,
                        selectedColor:
                            Color.fromARGB(255, 243, 77, 80).withOpacity(0.4),
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
                        }),
                  ],
                ),
              ),
              StreamBuilder<List<Block>>(
                  stream: BlockchainAPI.chainStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container(
                          color: Color.fromARGB(255, 241, 243, 245),
                          child: Expanded(
                              child: Center(child: Icon(Icons.error_outline))));
                    }

                    if (!snapshot.hasData) {
                      return Container(
                          color: Color.fromARGB(255, 241, 243, 245),
                          child: Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 70,
                                  width: 70,
                                  child: ImageSequenceAnimator(
                                    "res/progress_light",
                                    "loading 24dp-",
                                    0,
                                    1,
                                    "png",
                                    35,
                                    isLooping: true,
                                    isAutoPlay: true,
                                    key: Key("offline"),
                                    onReadyToPlay: onOfflineReadyToPlay,
                                    onPlaying: onOfflinePlaying,
                                    fps: 40,
                                  ),
                                ),
                                Text("Loading...")
                              ],
                            ),
                          ));
                    }

                    final steps = buildSteps(chain: snapshot.data!);

                    if (steps.isEmpty) {
                      steps.add(Step(
                        title: Text('No transaction'),
                        content: SizedBox(),
                      ));
                    }

                    return Stepper(
                      key: stepperKey,
                      physics: ClampingScrollPhysics(),
                      currentStep: currstep,
                      onStepTapped: (index) => setState(() => currstep = index),
                      controlsBuilder: (_, __) => SizedBox(),
                      steps: steps,
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  List<Step> buildSteps({required List<Block> chain}) {
    List<Step> steps = [];

    List<Block> blocks = chain;
    if (showm && !showum) {
      blocks = chain.where((block) => block.hash.isNotEmpty).toList();
    } else if (!showm && showum) {
      blocks = chain.where((block) => block.hash.isEmpty).toList();
    }

    for (int i = 0; i < blocks.length; i++) {
      Block b = blocks[i];
      if (b.hash.isEmpty) {
        b.title = "Unmined Transaction";
      }
      steps.add(Step(
        isActive: i == currstep,
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

    if (prevChainLength != chain.length) {
      prevChainLength = chain.length;
      stepperKey = UniqueKey();
    }

    return steps;
  }

  void onOfflineReadyToPlay(ImageSequenceAnimatorState _imageSequenceAnimator) {
    //offlineImageSequenceAnimator = _imageSequenceAnimator;
  }

  void onOfflinePlaying(ImageSequenceAnimatorState _imageSequenceAnimator) {
    // setState(() {});
  }
}
