import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:veatre/src/models/Crypto.dart';
import 'package:web3dart/src/utils/rlp.dart' as rlp;
import 'package:web3dart/crypto.dart';
import 'package:pointycastle/digests/blake2b.dart';

final int solo = 0xa4;
final int testNetwork = 0x27;
final int mainNetwork = 0x4a;
final BigInt initialBaseGasPrice = BigInt.from(1e15);

class Transaction {
  final int chainTag;

  final BlockRef blockRef;

  final int expiration;

  List<Clause> _clauses = [];
  List<Clause> get clauses {
    return _clauses;
  }

  int gasPriceCoef = 0;
  int gas = 0;

  Uint8List _dependsOn;
  Uint8List get dependsOn {
    return _dependsOn;
  }

  int _nonce = 0;
  int get nonce {
    return _nonce;
  }

  List<dynamic> _reserved = [];
  List<dynamic> get reserved {
    return _reserved;
  }

  Uint8List _signature;
  Uint8List get signature {
    return _signature;
  }

  Transaction({
    this.chainTag,
    this.blockRef,
    this.expiration,
    List<Clause> clauses,
    int gasPriceCoef = 0,
    int gas = 0,
    Uint8List dependsOn,
    int nonce = 0,
    List<dynamic> reserved,
  }) {
    this._clauses = clauses == null ? [] : clauses;
    this.gasPriceCoef = gasPriceCoef;
    this.gas = gas;
    this._dependsOn = dependsOn == null ? Uint8List(0) : dependsOn;
    this._reserved = reserved == null ? [] : reserved;
  }

  void sign(Uint8List privateKey) {
    this._signature = Crypto.sign(signingHash(), privateKey);
  }

  List<dynamic> _unserializedParams() {
    // print(
    //     "${this.chainTag} ${this.blockRef.number} ${this.expiration} ${this._clauses} ${this.gasPriceCoef} ${this.gas} ${this._dependsOn} ${this._nonce} ${this._reserved}");
    List<dynamic> data = [];
    data.addAll([
      this.chainTag,
      this.blockRef.number,
      this.expiration,
    ]);
    List<dynamic> clauseList = [];
    for (Clause clause in this._clauses) {
      clauseList.add(clause.encode());
    }
    data.add(clauseList);
    data.addAll([
      this.gasPriceCoef,
      this.gas,
      this._dependsOn,
      this._nonce,
      this._reserved
    ]);
    return data;
  }

  Uint8List unserialized() {
    return rlp.encode(_unserializedParams());
  }

  Uint8List signingHash() {
    Uint8List data = unserialized();
    Blake2bDigest blake2b = Blake2bDigest(digestSize: 32);
    return blake2b.process(data);
  }

  Uint8List serialized() {
    List unserializedParams = List.from(_unserializedParams());
    if (_signature.length > 0) {
      unserializedParams.add(this._signature);
    }
    return rlp.encode(unserializedParams);
  }
}

class BlockRef {
  int _number64;
  get number {
    return _number64;
  }

  BlockRef({int number32}) {
    Uint8List data = Uint8List(8);
    ByteData bdata = ByteData.view(data.buffer);
    bdata.setUint32(0, number32);
    this._number64 = bdata.getUint64(0);
  }
}

class Clause {
  Uint8List _to;
  Uint8List get to {
    return _to;
  }

  BigInt _value;
  BigInt get value {
    return _value;
  }

  Uint8List _data;
  Uint8List get data {
    return _data;
  }

  Clause({Uint8List to, BigInt value, Uint8List data}) {
    this._to = to == null ? Uint8List(0) : to;
    this._value = value == null ? BigInt.zero : value;
    this._data = data == null ? Uint8List(0) : data;
  }

  List<dynamic> encode() {
    return [to, value, data];
  }
}

class RawClause {
  final String to;

  final String value;

  final String data;

  final String comment;

  RawClause({this.to, this.value, this.data, this.comment});

  factory RawClause.fromJSON(Map<String, dynamic> parsedJson) {
    return RawClause(
      to: parsedJson['to'],
      value: parsedJson['value'],
      data: parsedJson['data'],
      comment: parsedJson['comment'],
    );
  }

  Clause toClause() {
    return Clause(
      to: hexToBytes(to),
      value: BigInt.parse(value),
      data: hexToBytes(data),
    );
  }
}

class Event {
  final String address;
  final List<String> topics;
  final String data;

  Event({this.address, this.topics, this.data});

  factory Event.fromJSON(Map<String, dynamic> parsedJson) {
    List<String> topics = [];
    for (String topic in parsedJson['topics']) {
      topics.add(topic);
    }
    return Event(
      address: parsedJson['address'],
      topics: topics,
      data: parsedJson['data'],
    );
  }
}

class Transfer {
  final String sender;
  final String recipient;
  final String amount;

  Transfer({this.sender, this.recipient, this.amount});

  factory Transfer.fromJSON(Map<String, dynamic> parsedJson) {
    return Transfer(
      sender: parsedJson['sender'],
      recipient: parsedJson['recipient'],
      amount: parsedJson['amount'],
    );
  }
}

class CallResult {
  final String data;
  final List<Event> events;
  final List<Transfer> transfers;
  final int gasUsed;
  final bool reverted;
  final String vmError;

  CallResult({
    this.data,
    this.events,
    this.transfers,
    this.gasUsed,
    this.reverted,
    this.vmError,
  });

  factory CallResult.fromJSON(Map<String, dynamic> parsedJson) {
    List<Event> events = [];
    for (Map<String, dynamic> event in parsedJson['events']) {
      events.add(Event.fromJSON(event));
    }
    List<Transfer> transfers = [];
    for (Map<String, dynamic> transfer in parsedJson['transfers']) {
      transfers.add(Transfer.fromJSON(transfer));
    }
    return CallResult(
      data: parsedJson['data'],
      events: events,
      transfers: transfers,
      gasUsed: parsedJson['gasUsed'],
      reverted: parsedJson['reverted'],
      vmError: parsedJson['vmError'],
    );
  }
}
