import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class EasyRefreshFooter extends StatefulWidget {
  /// 是否在加载
  final bool load;
  final bool willLoad;
  final Widget child;
  final double loadExtent;

  EasyRefreshFooter({
    Key key,
    this.load = false,
    this.willLoad = false,
    this.child,
    this.loadExtent,
  });

  @override
  _EasyRefreshFooterState createState() => _EasyRefreshFooterState();
}

class _EasyRefreshFooterState extends State<EasyRefreshFooter> {
  @override
  Widget build(BuildContext context) {
    return _EasyRefreshSliverLoad(
      load: widget.load,
      loadExtent: widget.loadExtent,
      child: LayoutBuilder(
        builder: (context, layout) {
          return Container(
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: widget.child ??
                      Container(
                        height: widget.loadExtent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(right: 10.0),
                              child: widget.load
                                  ? CupertinoActivityIndicator(
                                      radius: 12,
                                    )
                                  : Icon(
                                      widget.willLoad ? Icons.arrow_downward : Icons.arrow_upward,
                                    ),
                            ),
                            Text(
                              widget.load ? '正在加载' : widget.willLoad ? '松手开始加载' : '上拉开始加载',
                              style: TextStyle(fontSize: 16.0, color: Colors.black),
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

class _EasyRefreshSliverLoad extends SingleChildRenderObjectWidget {
  final bool load;
  final double loadExtent;

  const _EasyRefreshSliverLoad({
    Key key,
    Widget child,
    this.load = false,
    this.loadExtent,
  }) : super(key: key, child: child);

  @override
  _RenderEasyRefreshSliverLoad createRenderObject(BuildContext context) {
    return _RenderEasyRefreshSliverLoad(
      load: load,
      loadExtent: loadExtent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderEasyRefreshSliverLoad renderObject) {
    renderObject
      ..load = load
      ..loadExtent = loadExtent;
  }
}

class _RenderEasyRefreshSliverLoad extends RenderSliverSingleBoxAdapter {
  _RenderEasyRefreshSliverLoad({
    @required bool load,
    @required double loadExtent,
    RenderBox item,
  }) {
    this.child = item;
    _load = load;
    _loadExtent = loadExtent;
  }

  /// 加载状态
  bool get load => _load;
  bool _load;
  set load(bool value) {
    if (value == _load) return;
    _load = value;
    markNeedsLayout();
  }

  /// child高度
  double get loadExtent => _loadExtent;
  double _loadExtent;
  set loadExtent(double value) {
    if (value == _loadExtent) return;
    _loadExtent = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    /// 设置滑动时控件的高度
    geometry = SliverGeometry(
      scrollExtent: _load ? _loadExtent : 0.0,
      paintOrigin: 0.0,
      paintExtent: constraints.remainingPaintExtent,
      maxPaintExtent: constraints.remainingPaintExtent,
      layoutExtent: constraints.remainingPaintExtent,
    );

    /// 设置刷新控件的高度
    child.layout(
      constraints.asBoxConstraints(
        maxExtent: constraints.remainingPaintExtent,
      ),
      parentUsesSize: true,
    );
  }
}
