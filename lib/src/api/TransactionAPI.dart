import 'dart:typed_data';

import 'package:web3dart/crypto.dart';
import 'package:veatre/src/models/transaction.dart';
import 'package:veatre/src/storage/networkStorage.dart';

class TransactionAPI {
  static Future<Map<String, dynamic>> send(Uint8List raw) async {
    final net = await NetworkStorage.net;
    Map<String, dynamic> data =
        await net.senTransaction("0x" + bytesToHex(raw));
    return data;
  }

  static Future<List<Transfer>> filterTransfers(
    String address,
    int offset,
    int limit,
  ) async {
    String addr = address.startsWith('0x') ? address : '0x$address';
    final net = await NetworkStorage.net;
    dynamic data = await net.filterTransferLogs({
      "range": {
        "unit": "block",
        "from": 0,
        "to": 4294967295,
      },
      "options": {
        "offset": offset,
        "limit": limit,
      },
      "criteriaSet": [
        {"sender": addr},
        {"recipient": addr},
      ],
      "order": "desc"
    });
    List<Transfer> transfers = [];
    for (Map<String, dynamic> json in data) {
      transfers.add(Transfer.fromJSON(json));
    }
    return transfers;
  }
}
