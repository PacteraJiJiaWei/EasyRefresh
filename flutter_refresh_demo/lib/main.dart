import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'easy_refresh_header.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ListDemo(),
    );
  }
}

class ListDemo extends StatefulWidget {
  @override
  _ListDemoState createState() => _ListDemoState();
}

enum RefreshState {
  scrolling,
  refreshing,
  end,
}

class _ListDemoState extends State<ListDemo> {
  ScrollController controller;
  double height = 0.0;
  double begin;
  double end;
  bool refresh = false;
  bool willRefresh = false;
  ValueNotifier<bool> _callRefreshNotifier;

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
    _callRefreshNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _callRefreshNotifier.dispose();
  }

  upDateRefresh() {
    if (controller.offset > -60.0) {
      if (refresh) setState(() => refresh = false);
    } else {
      if (!refresh) setState(() => refresh = true);

      /// 延时结束刷新状态
      Future.delayed(Duration(seconds: 2), () {
        setState(() => refresh = false);
      });
    }
  }

  updateState() {
    if (controller.offset > -60.0) {
      if (willRefresh) setState(() => willRefresh = false);
    } else {
      if (!willRefresh) setState(() => willRefresh = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'EasyRefresh',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
          ),
          body: Container(
            color: Colors.white,
            child: Listener(
              onPointerUp: (event) {
                upDateRefresh();
              },
              onPointerMove: (event) {
                updateState();
              },
              child: CustomScrollView(
                controller: controller,
                slivers: [
                  EasyRefreshHeader(
                    refresh: refresh,
                    willRefresh: willRefresh,
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    return Container(
                      height: 100.0,
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(bottom: 4.0),
                      margin: EdgeInsets.all(1.0),
                      color: Colors.brown,
                      child: Column(
                        children: <Widget>[
                          Text(
                            "List item : $index",
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                            height: 2.0,
                          )
                        ],
                      ),
                    );
                  }, childCount: 10)),
                ],
                reverse: false,
                primary: false,
                shrinkWrap: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
