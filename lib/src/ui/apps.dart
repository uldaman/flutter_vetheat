import 'package:flutter/material.dart';
import 'package:veatre/common/globals.dart';
import 'package:veatre/src/api/DappAPI.dart';
import 'package:veatre/src/models/dapp.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:veatre/src/storage/bookmarkStorage.dart';
import 'package:veatre/src/storage/networkStorage.dart';

typedef onAppSelectedCallback = Future<void> Function(DApp app);
typedef onBookmarkSelectedCallback = Future<void> Function(Bookmark bookmark);

class DApps extends StatefulWidget {
  final Network network;
  final onAppSelectedCallback onAppSelected;
  final onBookmarkSelectedCallback onBookmarkSelected;

  DApps({
    this.network,
    this.onAppSelected,
    this.onBookmarkSelected,
  });

  @override
  DAppsState createState() {
    return DAppsState();
  }
}

class DAppsState extends State<DApps> {
  final int crossAxisCount = 4;
  final double crossAxisSpacing = 15;
  final double mainAxisSpacing = 15;
  List<Bookmark> bookmarks = [];
  List<DApp> recomendedApps = Globals.apps;

  @override
  void initState() {
    super.initState();
    syncApps();
    updateBookmarks();
  }

  Future<void> syncApps() async {
    List<DApp> apps = await DAppAPI.list();
    Globals.apps = apps;
    if (mounted) {
      setState(() {
        recomendedApps = apps;
      });
    }
  }

  Future<void> updateBookmarks() async {
    List<Bookmark> bookmarks = await BookmarkStorage.queryAll(widget.network);
    if (mounted) {
      setState(() {
        this.bookmarks = bookmarks;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(0),
        children: <Widget>[
          bookmarks.length > 0
              ? Padding(
                  child: Text(
                    'Bookmarks',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  padding: EdgeInsets.all(15),
                )
              : SizedBox(),
          bookmarks.length > 0 ? bookmarkApps : SizedBox(),
          recomendedApps.length > 0
              ? Padding(
                  child: Text(
                    'Recomends',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  padding: EdgeInsets.all(15),
                )
              : SizedBox(),
          recomendedApps.length > 0 ? recomendApps : SizedBox(),
        ],
      ),
    );
  }

  Widget get recomendApps => GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(15),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: recomendedApps.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              SizedBox(
                width: (MediaQuery.of(context).size.width -
                        crossAxisCount * crossAxisSpacing -
                        40) /
                    crossAxisCount,
                child: FlatButton(
                  onPressed: () async {
                    if (widget.onAppSelected != null) {
                      widget.onAppSelected(recomendedApps[index]);
                    }
                  },
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: recomendedApps[index].logo,
                    placeholder: (context, url) => SizedBox.fromSize(
                      size: Size.square(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      print("CachedNetworkImage error: $error");
                      return Image.asset("assets/blank.png");
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  recomendedApps[index].name ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(color: Colors.brown, fontSize: 10),
                ),
              ),
            ],
          );
        },
      );
  Widget get bookmarkApps => GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.all(15),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              SizedBox(
                width: (MediaQuery.of(context).size.width -
                        crossAxisCount * crossAxisSpacing -
                        40) /
                    crossAxisCount,
                child: FlatButton(
                  onPressed: () async {
                    if (widget.onBookmarkSelected != null) {
                      widget.onBookmarkSelected(bookmarks[index]);
                    }
                  },
                  child: CachedNetworkImage(
                    fit: BoxFit.fill,
                    imageUrl: bookmarks[index].favicon,
                    placeholder: (context, url) => SizedBox.fromSize(
                      size: Size.square(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        Image.asset("assets/blank.png"),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  bookmarks[index].title ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.brown, fontSize: 10),
                ),
              ),
            ],
          );
        },
      );
}
