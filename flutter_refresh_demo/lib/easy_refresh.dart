import 'package:flutter/material.dart';
import 'easy_refresh_footer.dart';
import 'easy_refresh_header.dart';

class EasyRefresh extends StatefulWidget {
  @override
  _EasyRefreshState createState() => _EasyRefreshState();
}

class _EasyRefreshState extends State<EasyRefresh> {
  ScrollController controller;
  bool refresh = false;
  bool willRefresh = false;
  bool load = false;
  bool willLoad = false;
  double scrollMaxExtent;

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
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

  updateRefreshState() {
    if (controller.offset > -60.0) {
      if (willRefresh) setState(() => willRefresh = false);
    } else {
      if (!willRefresh) setState(() => willRefresh = true);
    }
  }

  upDateLoad() {
    if (controller.offset < scrollMaxExtent + 60.0) {
      if (load) setState(() => load = false);
    } else {
      if (!load) setState(() => load = true);

      /// 延时结束刷新状态
      Future.delayed(Duration(seconds: 2), () {
        setState(() => load = false);
      });
    }
  }

  updateLoadState() {
    if (controller.offset < scrollMaxExtent + 60.0) {
      if (willLoad) setState(() => willLoad = false);
    } else {
      if (!willLoad) setState(() => willLoad = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (event) {
        // 监听滑动结束时
        upDateRefresh();
        upDateLoad();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            // 保存最大滚动范围
            scrollMaxExtent = notification.metrics.maxScrollExtent;
          } else if (notification is ScrollUpdateNotification) {
            // 监听滑动中
            updateRefreshState();
            updateLoadState();
          }
          return true;
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
              }, childCount: 10),
            ),
            EasyRefreshFooter(
              load: load,
              willLoad: willLoad,
              loadExtent: 60.0,
            ),
          ],
          reverse: false,
          primary: false,
          shrinkWrap: false,
        ),
      ),
    );

  }
}
