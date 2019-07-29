import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:veatre/common/net.dart';

class NetworkStorage {
  static final testnet = "https://sync-testnet.vechain.org";
  static final mainnet = "https://sync-mainnet.vechain.org";
  static final _storage = new FlutterSecureStorage();
  static final networkKey = "91e02cd2b8621d0c05197f645668c5c4"; // md5(network)

  static Future<void> set({bool isMainNet = true}) async {
    if (isMainNet) {
      await _storage.write(
        key: networkKey,
        value: mainnet,
      );
    } else {
      await _storage.write(
        key: networkKey,
        value: testnet,
      );
    }
  }

  static Future<String> get network async {
    String network = await _storage.read(key: networkKey);
    if (network == null) {
      await _storage.write(
        key: networkKey,
        value: mainnet,
      );
      return mainnet;
    }
    return network;
  }

  static Future<Net> get net async {
    String network = await NetworkStorage.network;
    return Net(network);
  }
}
