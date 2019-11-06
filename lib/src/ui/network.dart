import 'package:flutter/material.dart';
import 'package:veatre/common/globals.dart';
import 'package:veatre/src/storage/configStorage.dart';

class Networks extends StatefulWidget {
  static const routeName = '/networks';

  @override
  NetworksState createState() => NetworksState();
}

class NetworksState extends State<Networks> {
  Network network = Network.MainNet;

  @override
  void initState() {
    super.initState();
    Config.network.then((network) {
      setState(() {
        this.network = network;
      });
    });
  }

  Future<void> changeNet() async {
    final toNetwork =
        network == Network.MainNet ? Network.TestNet : Network.MainNet;
    await Config.setNetwork(toNetwork);
    setState(() {
      this.network = toNetwork;
    });
    Globals.updateNetwork(toNetwork);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.addAll([
      buildCell(
        'MainNet',
        network == Network.MainNet,
        () async {
          if (network == Network.TestNet) {
            await changeNet();
          }
        },
      ),
      buildCell(
        'TestNet',
        network == Network.TestNet,
        () async {
          if (network == Network.MainNet) {
            await changeNet();
          }
        },
      ),
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Networks',
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 10),
        children: widgets,
      ),
    );
  }

  Widget buildCell(String title, bool show, Function() onTap) {
    return Container(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 15),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
              ),
              show
                  ? Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: 15),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.check,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
      height: 60,
    );
  }
}
