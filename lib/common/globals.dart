import 'dart:core';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:veatre/src/storage/networkStorage.dart';
import 'package:veatre/src/models/block.dart';
import 'package:veatre/common/net.dart';

class Globals {
  static final Block mainNetGenesis = Block.fromJSON({
    "number": 0,
    "id": "0x00000000851caf3cfdb6e899cf5958bfb1ac3413d346d43539627e6be7ec1b4a",
    "size": 170,
    "parentID":
        "0xffffffff53616c757465202620526573706563742c20457468657265756d2100",
    "timestamp": 1530316800,
    "gasLimit": 10000000,
    "beneficiary": "0x0000000000000000000000000000000000000000",
    "gasUsed": 0,
    "totalScore": 0,
    "txsRoot":
        "0x45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0",
    "txsFeatures": 0,
    "stateRoot":
        "0x09bfdf9e24dd5cd5b63f3c1b5d58b97ff02ca0490214a021ed7d99b93867839c",
    "receiptsRoot":
        "0x45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0",
    "signer": "0x0000000000000000000000000000000000000000",
    "isTrunk": true,
    "transactions": []
  });

  static final Block testNetGenesis = Block.fromJSON({
    "number": 0,
    "id": "0x000000000b2bce3c70bc649a02749e8687721b09ed2e15997f466536b20bb127",
    "size": 170,
    "parentID":
        "0xffffffff00000000000000000000000000000000000000000000000000000000",
    "timestamp": 1530014400,
    "gasLimit": 10000000,
    "beneficiary": "0x0000000000000000000000000000000000000000",
    "gasUsed": 0,
    "totalScore": 0,
    "txsRoot":
        "0x45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0",
    "txsFeatures": 0,
    "stateRoot":
        "0x4ec3af0acbad1ae467ad569337d2fe8576fe303928d35b8cdd91de47e9ac84bb",
    "receiptsRoot":
        "0x45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0",
    "signer": "0x0000000000000000000000000000000000000000",
    "isTrunk": true,
    "transactions": []
  });

  static final testNet = Net(NetworkStorage.testnet);
  static final mainNet = Net(NetworkStorage.mainnet);

  static HeadController mainNetHeadController;
  static HeadController testNetHeadController;

  static List<String> testNetWallets;
  static List<String> mainNetWallets;

  static String connexJS;

  static List<String> walletsFor(Network network) {
    if (network == Network.MainNet) {
      return mainNetWallets;
    }
    return testNetWallets;
  }

  static get walletsForCurrentNet async {
    Network currentNet = await NetworkStorage.currentNet;
    return walletsFor(currentNet);
  }

  static Block genesisFor(Network network) {
    if (network == Network.MainNet) {
      return mainNetGenesis;
    }
    return testNetGenesis;
  }

  static Future<Block> get genesisForCurrentNet async {
    Network currentNet = await NetworkStorage.currentNet;
    return genesisFor(currentNet);
  }

  static Net netFor(Network network) {
    if (network == Network.MainNet) {
      return mainNet;
    }
    return testNet;
  }

  static Future<Net> get currentNet async {
    Network currentNet = await NetworkStorage.currentNet;
    return netFor(currentNet);
  }

  static Future<HeadController> get headControllerForCurrentNet async {
    Network currentNet = await NetworkStorage.currentNet;
    return headControllerFor(currentNet);
  }

  static HeadController headControllerFor(Network network) {
    if (network == Network.MainNet) {
      return mainNetHeadController;
    }
    return testNetHeadController;
  }

  static Timer periodic(
    int seconds,
    Future<void> Function(Timer timer) action,
  ) {
    return Timer.periodic(
      Duration(seconds: seconds),
      (timer) async {
        await action(timer);
      },
    );
  }
}

class HeadController extends ValueNotifier<BlockHead> {
  HeadController(BlockHead value) : super(value);
}

class WalletsController extends ValueNotifier<List<String>> {
  WalletsController(List<String> value) : super(value);
}