import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

import 'package:flutter/scheduler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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

enum RefreshState { scrolling, refreshing, end,}

class _ListDemoState extends State<ListDemo> {
  ScrollController controller;
  double height = 0.0;
  double begin;
  double end;
  bool refresh = false;
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

  upDate() {
    if (controller.offset > -60.0) {
      SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
        if (refresh) setState(() => refresh = false);
      });
    } else {
      SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
        if (!refresh) setState(() => refresh = true);
        /// 延时结束刷新状态
        Future.delayed(Duration(seconds: 2),() {
          if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
            setState(() => refresh = false);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.white,
            child: Listener(
              onPointerUp: (event) {
                upDate();
              },
              child: CustomScrollView(
                controller: controller,
                slivers: [
                  _EasyRefreshSliverRefresh(
                    refresh: refresh,
                    child: LayoutBuilder(
                      builder: (context, layout) {
                        return Container(
                          color: Colors.red,
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('1111'),
                                    Text('1111'),
                                    Text('1111'),
                                    Text('1111'),
                                    Text('1111'),
                                    Text('1111'),
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
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
                  }, childCount: 10))
                ],
                reverse: false,
//          controller: widget.scrollController,
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

class _EasyRefreshSliverRefresh extends SingleChildRenderObjectWidget {
  final bool refresh;

  const _EasyRefreshSliverRefresh({
    Key key,
    Widget child,
    this.refresh = false,
  }) : super(key: key, child: child);

  @override
  _RenderEasyRefreshSliverRefresh createRenderObject(BuildContext context) {
    return _RenderEasyRefreshSliverRefresh(refresh: refresh);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderEasyRefreshSliverRefresh renderObject) {
    renderObject..refresh = refresh;
  }
}

class _RenderEasyRefreshSliverRefresh extends RenderSliverSingleBoxAdapter {
  _RenderEasyRefreshSliverRefresh({
    @required bool refresh,
    RenderBox item,
  }) {
    this.child = item;
    _refresh = refresh;
  }

  bool get refresh => _refresh;
  bool _refresh;
  set refresh(bool value) {
    if (value == _refresh) return;
    _refresh = value;
    markNeedsLayout();
  }

  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {

    double refreshHeight = _refresh ? 60.0 : 0.0;
    double overscrolledExtent = constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;

    /// 用来做状态切换缓冲
    if (refreshHeight != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: refreshHeight - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = refreshHeight;
      return;
    }

    print(constraints.overlap);
    if (_refresh) {
      geometry = SliverGeometry(
        scrollExtent: refreshHeight, // 在当前的视图中，距离下方的距离
        paintOrigin: -overscrolledExtent - constraints.scrollOffset,
        paintExtent: min(max(refreshHeight - constraints.scrollOffset, 0.0), constraints.remainingPaintExtent),
        maxPaintExtent: max(refreshHeight - constraints.scrollOffset, 0.0),
        layoutExtent: max(refreshHeight - constraints.scrollOffset, 0.0),
      );

      child.layout(
        constraints.asBoxConstraints(
          maxExtent: refreshHeight + overscrolledExtent,
        ),
        parentUsesSize: true,
      );

    } else {

      if (constraints.overlap < 0.0) {
        geometry = SliverGeometry(
          scrollExtent: refreshHeight, // 在当前的视图中，距离下方的距离
          paintOrigin: -overscrolledExtent - constraints.scrollOffset,
          paintExtent: min(constraints.overlap.abs(), constraints.remainingPaintExtent),
          maxPaintExtent: constraints.overlap.abs(),
          layoutExtent: 0.0,
        );
      } else {
        geometry = SliverGeometry.zero;
      }

      child.layout(
        constraints.asBoxConstraints(
          maxExtent: constraints.overlap.abs(),
        ),
        parentUsesSize: true,
      );

    }
  }
}
