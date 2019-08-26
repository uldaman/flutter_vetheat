import 'package:sqflite/sqflite.dart';
import 'package:veatre/src/storage/database.dart';
import 'package:veatre/src/storage/networkStorage.dart';

class ActivityStorage {
  static Future<void> insert(Activity activity) async {
    final db = await database;
    await db.insert(
      activityTableName,
      activity.encoded,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> update(int id, Map<String, dynamic> values) async {
    final db = await database;
    await db.update(
      activityTableName,
      values,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  static Future<List<Activity>> queryPendings(Network network) async {
    final Database db = await database;
    List<Map<String, dynamic>> rows = await db.query(
      activityTableName,
      where: 'status = ? and network = ?',
      whereArgs: [
        ActivityStatus.Pending.index,
        network == Network.MainNet ? 0 : 1
      ],
    );
    return List.from(rows.map((row) => Activity.fromJSON(row)));
  }

  static Future<List<Activity>> queryAll(Network network) async {
    final db = await database;
    List<Map<String, dynamic>> rows = await db.query(
      activityTableName,
      where: 'network = ?',
      whereArgs: [network == Network.MainNet ? 0 : 1],
      orderBy: 'timestamp desc',
    );
    return List.from(rows.map((row) => Activity.fromJSON(row)));
  }
}

enum ActivityType {
  Transaction,
  Certificate,
}

enum ActivityStatus {
  Pending,
  Finished,
  Expired,
  Reverted,
}

class Activity {
  int id;
  String hash;
  int block;
  int processBlock;
  String content;
  String link;
  String walletName;
  ActivityType type;
  String comment;
  int timestamp;
  ActivityStatus status; // 0 pending 1 finished 2 reverted
  Network network;

  Activity({
    this.id,
    this.hash,
    this.block,
    this.processBlock,
    this.content,
    this.link,
    this.walletName,
    this.type,
    this.comment,
    this.timestamp,
    this.status,
    this.network,
  });

  Map<String, dynamic> get encoded {
    return {
      'hash': hash,
      'block': block,
      'processBlock': processBlock,
      'content': content,
      'link': link,
      'walletName': walletName,
      'type': type.index,
      'comment': comment,
      'timestamp': timestamp,
      'status': status.index,
      'network': network == Network.MainNet ? 0 : 1,
    };
  }

  factory Activity.fromJSON(Map<String, dynamic> parsedJSON) {
    return Activity(
      id: parsedJSON['id'],
      hash: parsedJSON['hash'],
      block: parsedJSON['block'],
      processBlock: parsedJSON['processBlock'],
      content: parsedJSON['content'],
      link: parsedJSON['link'],
      walletName: parsedJSON['walletName'],
      type: parsedJSON['type'] == ActivityType.Transaction.index
          ? ActivityType.Transaction
          : ActivityType.Certificate,
      comment: parsedJSON['comment'],
      timestamp: parsedJSON['timestamp'],
      status: parsedJSON['status'] == ActivityStatus.Pending.index
          ? ActivityStatus.Pending
          : parsedJSON['status'] == ActivityStatus.Finished.index
              ? ActivityStatus.Finished
              : parsedJSON['status'] == ActivityStatus.Reverted.index
                  ? ActivityStatus.Reverted
                  : ActivityStatus.Expired,
      network: parsedJSON['network'] == 0 ? Network.MainNet : Network.TestNet,
    );
  }
}
