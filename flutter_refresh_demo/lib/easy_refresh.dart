import 'package:flutter/material.dart';
import 'easy_refresh_footer.dart';
import 'easy_refresh_header.dart';

typedef EasyRefreshCompere = Function(BuildContext context);
typedef EasyRefreshItem = Widget Function(BuildContext context, EasyRefreshState state);
typedef EasyRefreshSliverItem = Widget Function(BuildContext context, int index);

enum EasyRefreshState {
  will,
  start,
  cancel,
}

class EasyRefresh extends StatefulWidget {
  /// 下拉刷新回调
  final EasyRefreshCompere refresh;

  /// 下拉刷新状态变化距离
  final double refreshExtent;

  /// 下拉刷新自定义视图
  final EasyRefreshItem header;

  /// 上拉加载回调
  final EasyRefreshCompere load;

  /// 上拉加载状态变化距离
  final double loadExtent;

  /// 上拉加载自定义视图
  final EasyRefreshItem footer;

  /// 刷新listItem
  final EasyRefreshSliverItem item;

  /// 子控件数量
  final int itemCount;

  EasyRefresh({
    Key key,
    this.refresh,
    this.refreshExtent = 60.0,
    this.header,
    this.load,
    this.loadExtent = 40.0,
    this.footer,
    this.item,
    this.itemCount,
  });

  @override
  _EasyRefreshState createState() => _EasyRefreshState();

  /// 用来获取当前的state
  static _EasyRefreshState of(BuildContext context) {
    return context.findAncestorStateOfType<_EasyRefreshState>();
  }
}

class _EasyRefreshState extends State<EasyRefresh> {
  // 滑动控制器
  ScrollController controller;
  // 是否开始下拉刷新
  bool refresh = false;
  // 是否是将要刷新状态
  bool willRefresh = false;
  // 是否开始上拉加载
  bool load = false;
  // 是否是将要上拉加载状态
  bool willLoad = false;
  // 可滑动的最大距离
  double scrollMaxExtent;

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
  }

  upDateRefresh(BuildContext context) {
    if (controller.offset > -widget.refreshExtent) {
      if (refresh) setState(() => refresh = false);
    } else {
      if (!refresh) {
        setState(() => refresh = true);
        if (widget.refresh != null) widget.refresh(context);
      }
    }
  }

  stopRefresh() {
    setState(() => refresh = false);
  }

  updateRefreshState() {
    if (controller.offset > -widget.refreshExtent) {
      if (willRefresh) setState(() => willRefresh = false);
    } else {
      if (!willRefresh) setState(() => willRefresh = true);
    }
  }

  upDateLoad(BuildContext context) {
    if (controller.offset < scrollMaxExtent + widget.loadExtent) {
      if (load) setState(() => load = false);
    } else {
      if (!load) {
        setState(() => load = true);
        if (widget.load != null) widget.load(context);
      }
    }
  }

  stopLoad() {
    setState(() => load = false);
  }

  updateLoadState() {
    if (controller.offset < scrollMaxExtent + widget.loadExtent) {
      if (willLoad) setState(() => willLoad = false);
    } else {
      if (!willLoad) setState(() => willLoad = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return Listener(
          onPointerUp: (event) {
            // 监听手指抬起时
            if (widget.refresh != null) upDateRefresh(context);
            if (widget.load != null) upDateLoad(context);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollStartNotification) {
                // 保存最大滚动范围
                scrollMaxExtent = notification.metrics.maxScrollExtent;
              } else if (notification is ScrollUpdateNotification) {
                // 监听滑动中状态变化
                if (widget.refresh != null) updateRefreshState();
                if (widget.load != null) updateLoadState();
              }
              return true;
            },
            child: CustomScrollView(
              controller: controller,
              slivers: [
                EasyRefreshHeader(
                  refresh: refresh,
                  willRefresh: willRefresh,
                  refreshExtent: widget.refreshExtent,
                  child: widget.header != null
                      ? widget.header(
                          context,
                          refresh
                              ? EasyRefreshState.start
                              : willRefresh ? EasyRefreshState.will : EasyRefreshState.cancel,
                        )
                      : null,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      if (widget.item != null) {
                        return widget.item(context, index);
                      }
                      return SizedBox();
                    },
                    childCount: widget.itemCount,
                  ),
                ),
                EasyRefreshFooter(
                  load: load,
                  willLoad: willLoad,
                  loadExtent: widget.loadExtent,
                  child: widget.footer != null
                      ? widget.footer(
                          context,
                          refresh
                              ? EasyRefreshState.start
                              : willRefresh ? EasyRefreshState.will : EasyRefreshState.cancel,
                        )
                      : null,
                ),
              ],
              reverse: false,
              primary: false,
              shrinkWrap: false,
            ),
          ),
        );
      },
    );
  }
}
