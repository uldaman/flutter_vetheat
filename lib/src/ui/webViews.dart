import 'dart:async';
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:webview_flutter/webview_flutter.dart' as FlutterWebView;
import 'package:veatre/src/storage/networkStorage.dart';
import 'package:veatre/src/ui/webView.dart';

class Snapshot {
  String title;
  Uint8List data;

  Snapshot({
    this.title,
    this.data,
  });
}

List<Snapshot> _mainNetSnapshots = [];
List<WebView> mainNetWebViews = [];

List<Snapshot> _testNetSnapshots = [];
List<WebView> testNetWebViews = [];

void createWebView(Network network, onWebViewChangedCallback onWebViewChanged) {
  int id = network == Network.MainNet
      ? mainNetWebViews.length
      : testNetWebViews.length;
  LabeledGlobalKey<WebViewState> key = LabeledGlobalKey<WebViewState>(
      network == Network.MainNet ? 'mainNetWebView$id' : 'testNetWebView$id');
  WebView webView = new WebView(
    key: key,
    network: network,
    onWebViewChanged: (controller) async {
      onWebViewChanged(controller);
    },
  );
  if (network == Network.MainNet) {
    _mainNetSnapshots.add(Snapshot());
    mainNetWebViews.add(webView);
  } else {
    _testNetSnapshots.add(Snapshot());
    testNetWebViews.add(webView);
  }
}

void updateSnapshot(
  Network net,
  int id, {
  Uint8List data,
  String title,
}) {
  if (net == Network.MainNet) {
    _mainNetSnapshots[id] = Snapshot(
      data: data,
      title: title.length > 16 ? title.substring(0, 16) : title,
    );
  } else {
    _testNetSnapshots[id] = Snapshot(
      data: data,
      title: title.length > 16 ? title.substring(0, 16) : title,
    );
  }
}

int tabshotLen(Network net) {
  if (net == Network.MainNet) {
    return _mainNetSnapshots.length;
  }
  return _testNetSnapshots.length;
}

void removeTab(Network net, int id) {
  if (net == Network.MainNet) {
    mainNetWebViews.removeAt(id);
    _mainNetSnapshots.removeAt(id);
  } else {
    testNetWebViews.removeAt(id);
    _testNetSnapshots.removeAt(id);
  }
}

void removeAllTabs(Network net) {
  if (net == Network.MainNet) {
    _mainNetSnapshots.clear();
    mainNetWebViews.clear();
  } else {
    _testNetSnapshots.clear();
    testNetWebViews.clear();
  }
}

FlutterWebView.WebViewController _controllerAt(Network net, int id) {
  final key = _keyAt(net, id);
  if (key != null && key.currentState != null) {
    return key.currentState.controller;
  }
  return null;
}

LabeledGlobalKey<WebViewState> _keyAt(Network net, int id) {
  if (net == Network.MainNet) {
    return mainNetWebViews[id].key;
  }
  return testNetWebViews[id].key;
}

List<Snapshot> snapshots(Network net) {
  if (net == Network.MainNet) {
    return _mainNetSnapshots;
  }
  return _testNetSnapshots;
}

Future<String> getTitle(Network net, int id) async {
  final controller = _controllerAt(net, id);
  if (controller != null) {
    return controller.currentTitle();
  }
  return null;
}

Future<bool> canGoBack(Network net, int id) async {
  final controller = _controllerAt(net, id);
  if (controller != null) {
    return controller.canGoBack();
  }
  return false;
}

Future<bool> canGoForward(Network net, int id) async {
  final controller = _controllerAt(net, id);
  if (controller != null) {
    return controller.canGoForward();
  }
  return false;
}

Future<void> goBack(Network net, int id) async {
  final controller = _controllerAt(net, id);
  if (controller != null) {
    return controller.goBack();
  }
}

Future<void> goForward(Network net, int id) async {
  final controller = _controllerAt(net, id);
  if (controller != null) {
    return controller.goForward();
  }
}

Future<void> reload(Network net, int id) async {
  try {
    final controller = _controllerAt(net, id);
    if (controller != null) {
      return controller.reload();
    }
  } catch (err) {
    throw err;
  }
}

Future<void> loadUrl(Network net, int id, String url) async {
  try {
    final controller = _controllerAt(net, id);
    if (controller != null) {
      return controller.loadUrl(url);
    }
  } catch (err) {
    throw err;
  }
}

Future<Uint8List> takeScreenshot(Network net, int id) async {
  final key = _keyAt(net, id);
  if (key.currentState.isStartSearch ||
      key.currentState.currentURL == 'about:blank') {
    try {
      RenderRepaintBoundary boundary =
          key.currentState.captureKey.currentContext.findRenderObject();
      var image = await boundary.toImage(pixelRatio: 1.0);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List bytes = byteData.buffer.asUint8List();
      return bytes;
    } catch (e) {
      print("takeScreenshot error: $e");
      return null;
    }
  } else if (key.currentState.controller != null) {
    return key.currentState.controller.takeScreenshot();
  }
  return null;
}
