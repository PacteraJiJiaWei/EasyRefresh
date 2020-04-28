import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';

class EasyRefreshHeader extends StatefulWidget {
  /// 是否在刷新
  final bool refresh;
  final bool willRefresh;
  final Widget child;
  final double refreshExtent;

  EasyRefreshHeader({
    Key key,
    this.refresh = false,
    this.willRefresh = false,
    this.child,
    this.refreshExtent,
  });

  @override
  _EasyRefreshHeaderState createState() => _EasyRefreshHeaderState();
}

class _EasyRefreshHeaderState extends State<EasyRefreshHeader> {
  @override
  Widget build(BuildContext context) {
    return _EasyRefreshSliverRefresh(
      refresh: widget.refresh,
      refreshExtent: widget.refreshExtent,
      child: LayoutBuilder(
        builder: (context, layout) {
          return Container(
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: widget.child ??
                      Container(
                        height: widget.refreshExtent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: widget.refresh
                                  ? CupertinoActivityIndicator(
                                      radius: 12,
                                    )
                                  : Icon(
                                      widget.willRefresh ? Icons.arrow_upward : Icons.arrow_downward,
                                    ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  widget.refresh ? '正在刷新' : widget.willRefresh ? '松手开始刷新' : '下拉开始刷新',
                                  style: TextStyle(fontSize: 16.0, color: Colors.black),
                                ),
                                Text(
                                  'updateTime 9:00',
                                  style: TextStyle(fontSize: 14.0, color: Colors.cyan),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EasyRefreshSliverRefresh extends SingleChildRenderObjectWidget {
  final bool refresh;
  final double refreshExtent;

  const _EasyRefreshSliverRefresh({
    Key key,
    Widget child,
    this.refresh = false,
    this.refreshExtent,
  }) : super(key: key, child: child);

  @override
  _RenderEasyRefreshSliverRefresh createRenderObject(BuildContext context) {
    return _RenderEasyRefreshSliverRefresh(
      refresh: refresh,
      refreshExtent: refreshExtent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderEasyRefreshSliverRefresh renderObject) {
    renderObject
      ..refresh = refresh
      ..refreshExtent = refreshExtent;
  }
}

class _RenderEasyRefreshSliverRefresh extends RenderSliverSingleBoxAdapter {
  _RenderEasyRefreshSliverRefresh({
    @required bool refresh,
    @required double refreshExtent,
    RenderBox item,
  }) {
    this.child = item;
    _refresh = refresh;
    _refreshExtent = refreshExtent;
  }

  /// 刷新状态
  bool get refresh => _refresh;
  bool _refresh;
  set refresh(bool value) {
    if (value == _refresh) return;
    _refresh = value;
    markNeedsLayout();
  }

  /// child高度
  double get refreshExtent => _refreshExtent;
  double _refreshExtent;
  set refreshExtent(double value) {
    if (value == _refreshExtent) return;
    _refreshExtent = value;
    markNeedsLayout();
  }

  double layoutExtentOffsetCompensation = 0.0;

  @override
  void performLayout() {

    double refreshHeight = _refresh ? _refreshExtent : 0.0;
    double scrollExtent = constraints.overlap < 0.0 ? constraints.overlap.abs() : 0.0;

    /// 用来做状态切换缓冲
    if (refreshHeight != layoutExtentOffsetCompensation) {
      geometry = SliverGeometry(
        scrollOffsetCorrection: refreshHeight - layoutExtentOffsetCompensation,
      );
      layoutExtentOffsetCompensation = refreshHeight;
      return;
    }

    if (_refresh) {
      /// 设置刷新中的高度
      geometry = SliverGeometry(
        scrollExtent: refreshHeight,
        paintOrigin: -scrollExtent - constraints.scrollOffset,
        paintExtent: min(max(refreshHeight - constraints.scrollOffset, 0.0), constraints.remainingPaintExtent),
        maxPaintExtent: max(refreshHeight - constraints.scrollOffset, 0.0),
        layoutExtent: max(refreshHeight - constraints.scrollOffset, 0.0),
      );
    } else {
      /// 设置未刷新切滑动时的高度
      if (constraints.overlap < 0.0) {
        geometry = SliverGeometry(
          scrollExtent: refreshHeight,
          paintOrigin: -scrollExtent,
          paintExtent: scrollExtent,
          maxPaintExtent: scrollExtent,
          layoutExtent: 0.0,
        );
      } else {
        /// 设置没有滑动时的高度
        geometry = SliverGeometry.zero;
      }
    }

    /// 设置刷新控件的高度
    child.layout(
      constraints.asBoxConstraints(
        maxExtent: refreshHeight + scrollExtent,
      ),
      parentUsesSize: true,
    );
  }
}
