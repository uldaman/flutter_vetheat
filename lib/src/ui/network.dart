import 'package:flutter/material.dart';
import 'package:veatre/src/models/block.dart';
import 'package:veatre/src/storage/networkStorage.dart';
import 'package:veatre/main.dart';
import 'package:veatre/common/driver.dart';

class Networks extends StatefulWidget {
  static const routeName = '/networks';

  @override
  NetworksState createState() => NetworksState();
}

class NetworksState extends State<Networks> {
  bool isMainnet = true;

  @override
  void initState() {
    super.initState();
    NetworkStorage.network.then((network) {
      if (network == NetworkStorage.mainnet) {
        setState(() {
          isMainnet = true;
        });
      } else {
        setState(() {
          isMainnet = false;
        });
      }
    });
  }

  Future<void> changeNet() async {
    await NetworkStorage.set(isMainNet: !isMainnet);
    Driver _driver = await Driver.instance;
    headController.value = Block.fromJSON(await _driver.head);
    genesisController.value = await Driver.genesis;
    setState(() {
      isMainnet = !isMainnet;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.addAll([
      buildCell(
        'Mainnet',
        isMainnet,
        () async {
          if (!isMainnet) {
            await changeNet();
          }
        },
      ),
      buildCell(
        'Testnet',
        !isMainnet,
        () async {
          if (isMainnet) {
            await changeNet();
          }
        },
      ),
    ]);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Networks'),
        centerTitle: true,
      ),
      body: ListView(
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
                  style: TextStyle(fontSize: 18, color: Colors.black54),
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
                            color: Colors.grey,
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
