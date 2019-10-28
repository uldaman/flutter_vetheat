import 'dart:convert';
import 'package:veatre/common/globals.dart';
import 'package:veatre/src/utils/common.dart';
import 'package:veatre/src/models/account.dart';
import 'package:veatre/src/models/crypto.dart';
import 'package:veatre/src/storage/database.dart';
import 'package:veatre/src/storage/configStorage.dart';

class WalletStorage {
  static Future<List<WalletEntity>> readAll({Network network}) async {
    final db = await Storage.instance;
    List<Map<String, dynamic>> rows = await db.query(
      walletTableName,
      where: 'network = ?',
      whereArgs: [(network ?? Globals.network) == Network.MainNet ? 0 : 1],
      orderBy: 'id desc',
    );
    return List.from(rows.map((row) => WalletEntity.fromJSON(row)));
  }

  static Future<List<String>> wallets({Network network}) async {
    final db = await Storage.instance;
    List<Map<String, dynamic>> rows = await db.query(
      walletTableName,
      where: 'network = ?',
      whereArgs: [(network ?? Globals.network) == Network.MainNet ? 0 : 1],
      orderBy: 'id desc',
    );
    return List.from(
        rows.map((row) => '0x${WalletEntity.fromJSON(row).address}'));
  }

  static Future<int> count({Network network}) async {
    final db = await Storage.instance;
    List<Map<String, dynamic>> rows = await db.query(
      walletTableName,
      where: 'network = ?',
      whereArgs: [(network ?? Globals.network) == Network.MainNet ? 0 : 1],
      orderBy: 'id desc',
    );
    return rows.length;
  }

  static Future<bool> hasName(String name, {Network network}) async {
    final db = await Storage.instance;
    List<Map<String, dynamic>> rows = await db.query(
      walletTableName,
      where: 'name = ? and network = ?',
      whereArgs: [
        name,
        (network ?? Globals.network) == Network.MainNet ? 0 : 1
      ],
      orderBy: 'id desc',
    );
    return rows.length != 0;
  }

  static Future<void> updateName(String address, String name,
      {Network network}) async {
    final db = await Storage.instance;
    await db.update(
      walletTableName,
      {'name': name},
      where: 'address = ? and network = ? ',
      whereArgs: [
        address,
        (network ?? Globals.network) == Network.MainNet ? 0 : 1
      ],
    );
  }

  static Future<void> updateHasBackup(
    String address,
    bool hasBackup, {
    Network network,
  }) async {
    final db = await Storage.instance;
    await db.update(
      walletTableName,
      {'hasBackup': hasBackup ? 0 : 1},
      where: 'address = ? and network = ? ',
      whereArgs: [
        address,
        (network ?? Globals.network) == Network.MainNet ? 0 : 1
      ],
    );
  }

  static Future<bool> hasWallet(String address, {Network network}) async {
    final db = await Storage.instance;
    List<Map<String, dynamic>> rows = await db.query(
      walletTableName,
      where: 'address = ? and network = ?',
      whereArgs: [
        address,
        (network ?? Globals.network) == Network.MainNet ? 0 : 1
      ],
      orderBy: 'id desc',
    );
    return rows.length != 0;
  }

  static Future<WalletEntity> read(String address, {Network network}) async {
    final db = await Storage.instance;
    List<Map<String, dynamic>> rows = await db.query(
      walletTableName,
      where: 'address = ? and network = ?',
      whereArgs: [
        address,
        (network ?? Globals.network) == Network.MainNet ? 0 : 1
      ],
      orderBy: 'id desc',
    );
    if (rows.length == 0) {
      return null;
    }
    return WalletEntity.fromJSON(rows.first);
  }

  static Future<void> write(WalletEntity walletEntity,
      {Network network}) async {
    walletEntity.network = network ?? Globals.network;
    final db = await Storage.instance;
    List<Map<String, dynamic>> rows = await db.query(
      walletTableName,
      where: 'address = ? and network = ?',
      whereArgs: [
        walletEntity.address,
        walletEntity.network == Network.MainNet ? 0 : 1
      ],
      orderBy: 'id desc',
    );
    if (rows.length == 0) {
      return db.insert(walletTableName, walletEntity.encoded);
    }
    return db.update(
      walletTableName,
      walletEntity.encoded,
      where: 'address = ? and network = ?',
      whereArgs: [
        walletEntity.address,
        walletEntity.network == Network.MainNet ? 0 : 1,
      ],
    );
  }

  static Future<void> setMainWallet(WalletEntity walletEntity,
      {Network network}) async {
    final db = await Storage.instance;
    final batch = db.batch();
    network = network ?? Globals.network;
    batch.update(
      walletTableName,
      {
        'isMain': 1,
      },
      where: 'isMain != ? and network = ?',
      whereArgs: [
        1,
        network == Network.MainNet ? 0 : 1,
      ],
    );
    batch.update(
      walletTableName,
      {
        'isMain': 0,
      },
      where: 'address = ? and network = ?',
      whereArgs: [
        walletEntity.address,
        network == Network.MainNet ? 0 : 1,
      ],
    );
    await batch.commit(noResult: true);
  }

  static Future<WalletEntity> getMainWallet({Network network}) async {
    final db = await Storage.instance;
    List<Map<String, dynamic>> rows = await db.query(
      walletTableName,
      where: 'isMain = ? and network = ?',
      whereArgs: [
        0,
        (network ?? Globals.network) == Network.MainNet ? 0 : 1,
      ],
      orderBy: 'id desc',
    );
    if (rows.length == 0) {
      return null;
    }
    return WalletEntity.fromJSON(rows.first);
  }

  static Future<WalletEntity> getWalletEntity(String signer) async {
    if (signer != null) {
      List<WalletEntity> walletEntities = await WalletStorage.readAll();
      for (WalletEntity walletEntity in walletEntities) {
        if ('0x' + walletEntity.address == signer) {
          return walletEntity;
        }
      }
    }
    WalletEntity mianWalletEntity = await WalletStorage.getMainWallet();
    if (mianWalletEntity != null) {
      return mianWalletEntity;
    }
    List<WalletEntity> walletEntities = await WalletStorage.readAll();
    return walletEntities[0];
  }

  static Future<void> delete(String address, {Network network}) async {
    final db = await Storage.instance;
    await db.delete(
      walletTableName,
      where: 'address = ? and network = ?',
      whereArgs: [
        address,
        (network ?? Globals.network) == Network.MainNet ? 0 : 1,
      ],
    );
  }

  static Future<void> saveWallet(
    String address,
    String name,
    String mnemonic,
    String password, {
    Network network,
  }) async {
    final mnemonicData = utf8.encode(mnemonic);
    final iv = randomBytes(16);
    final mnemonicCipher = AESCipher.encrypt(
      utf8.encode(password),
      mnemonicData,
      iv,
    );
    final WalletEntity walletEntity = WalletEntity(
      name: name,
      address: address,
      mnemonicCipher: bytesToHex(mnemonicCipher),
      iv: bytesToHex(iv),
      isMain: true,
      hasBackup: false,
      network: network ?? Globals.network,
    );
    await WalletStorage.write(walletEntity);
    await WalletStorage.setMainWallet(walletEntity, network: network);
  }

  static Future<WalletEntity> getWalletEntity(
    Network network,
    String address,
  ) async {
    if (address != null) {
      List<WalletEntity> walletEntities = await WalletStorage.readAll(network);
      for (WalletEntity walletEntity in walletEntities) {
        if ('0x' + walletEntity.address == address) {
          return walletEntity;
        }
      }
    }

    WalletEntity mianWalletEntity = await WalletStorage.getMainWallet(network);
    if (mianWalletEntity != null) {
      return mianWalletEntity;
    }

    List<WalletEntity> walletEntities = await WalletStorage.readAll(network);
    return walletEntities[0];
  }
}
