import 'dart:typed_data';
import 'package:veatre/common/globals.dart';
import 'package:veatre/src/storage/configStorage.dart';
import 'package:veatre/src/ui/webView.dart';
import 'package:veatre/src/utils/common.dart';

class Snapshot {
  int id;
  String key;
  Uint8List data;
  String title;
  String url;
  int timestamp;
  bool isAlive;

  Snapshot({
    this.id,
    this.key,
    this.title,
    this.data,
    this.url,
    this.timestamp,
    this.isAlive = true,
  });
}

class WebViews {
  static Map<String, Snapshot> _mainNetSnapshots = {};
  static List<WebView> mainNetWebViews = [];

  static Map<String, Snapshot> _testNetSnapshots = {};
  static List<WebView> testNetWebViews = [];

  static final maxTabLen = 5;

  static void removeSnapshot(String key, {Network network}) {
    if ((network ?? Globals.network) == Network.MainNet) {
      _mainNetSnapshots.remove(key);
    } else {
      _testNetSnapshots.remove(key);
    }
  }

  static void removeWebview(int id, {Network network}) {
    Globals.updateTabValue(
      TabControllerValue(
        id: id,
        network: network ?? Globals.network,
        stage: TabStage.Removed,
      ),
    );
  }

  static void _createTab(
    List<WebView> webViews,
    Map<String, Snapshot> snapshots,
    String tabKey,
    Network network,
  ) {
    if (webViews.length < maxTabLen) {
      final id = webViews.length;
      WebView webView = WebView(
        id: id,
        offstage: false,
        network: network,
        initialURL: Globals.initialURL,
        tabKey: randomHex(32),
      );
      webViews.add(webView);
      Globals.updateTabValue(
        TabControllerValue(
          id: id,
          network: network,
          stage: TabStage.Created,
          tabKey: tabKey,
        ),
      );
    } else {
      int id = _unusedId(webViews, snapshots);
      int time = 0;
      if (id == null) {
        id = snapshots.values.first.id;
        time = snapshots.values.first.timestamp;
        for (var entry in snapshots.entries) {
          Snapshot snapshot = entry.value;
          if (time > snapshot.timestamp) {
            time = snapshot.timestamp;
            id = snapshot.id;
          }
        }
        Globals.updateTabValue(
          TabControllerValue(
            id: id,
            network: network,
            stage: TabStage.Coverred,
            tabKey: tabKey,
          ),
        );
      } else {
        Globals.updateTabValue(
          TabControllerValue(
            id: id,
            network: network,
            stage: TabStage.Coverred,
            tabKey: tabKey,
          ),
        );
      }
    }
  }

  static int _unusedId(
    List<WebView> webViews,
    Map<String, Snapshot> snapshots,
  ) {
    List<int> ids = [];
    for (final webView in webViews) {
      ids.add(webView.id);
    }
    List<int> snapshotIds = [];
    for (final snapshot in snapshots.values) {
      if (!snapshotIds.contains(snapshot.id)) {
        snapshotIds.add(snapshot.id);
      }
    }
    if (snapshotIds.length == ids.length) {
      return null;
    }
    for (final id in ids) {
      if (!snapshotIds.contains(id)) {
        return id;
      }
    }
    return null;
  }

  static void create({Network network}) {
    final tabKey = randomHex(32);
    network = network ?? Globals.network;
    if (network == Network.MainNet) {
      _createTab(mainNetWebViews, _mainNetSnapshots, tabKey, network);
    } else {
      _createTab(testNetWebViews, _testNetSnapshots, tabKey, network);
    }
  }

  static void _setSnapshot(
    Map<String, Snapshot> snapshots,
    String key,
    Snapshot snapshot,
  ) {
    for (var entry in snapshots.entries) {
      Snapshot entrySnapshot = entry.value;
      if (entrySnapshot.id == snapshot.id) {
        snapshots[entrySnapshot.key].isAlive = false;
      }
    }
    snapshots[key] = snapshot;
  }

  static void updateSnapshot(
    int id,
    String key,
    Network network, {
    Uint8List data,
    String title,
    String url,
  }) {
    Snapshot snapshot = Snapshot(
      id: id,
      key: key,
      data: data,
      title: title,
      url: url,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isAlive: true,
    );
    if (network == Network.MainNet) {
      _setSnapshot(_mainNetSnapshots, key, snapshot);
    } else {
      _setSnapshot(_testNetSnapshots, key, snapshot);
    }
  }

  static Snapshot getSnapshot(String key, {Network network}) {
    network = network ?? Globals.network;
    if (network == Network.MainNet) {
      return _mainNetSnapshots[key];
    } else {
      return _testNetSnapshots[key];
    }
  }

  static void removeAll({Network network}) {
    network = network ?? Globals.network;
    if (network == Network.MainNet) {
      _mainNetSnapshots.clear();
    } else {
      _testNetSnapshots.clear();
    }
    Globals.updateTabValue(
      TabControllerValue(
        id: 0,
        network: network,
        stage: TabStage.RemoveAll,
      ),
    );
  }

  static List<Snapshot> snapshots({Network network}) {
    if ((network ?? Globals.network) == Network.MainNet) {
      return List.from(_mainNetSnapshots.values);
    }
    return List.from(_testNetSnapshots.values);
  }
}
