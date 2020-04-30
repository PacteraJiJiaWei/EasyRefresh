import 'package:flutter/material.dart';
import 'easy_refresh_footer.dart';
import 'easy_refresh_header.dart';
export 'easy_refresh_footer.dart';
export 'easy_refresh_header.dart';

typedef EasyRefreshCompere = Function(BuildContext context);
typedef EasyRefreshHeaderItem = Widget Function(BuildContext context, RefreshState state, double offset);
typedef EasyRefreshFooterItem = Widget Function(BuildContext context, LoadState state, double offset);
typedef EasyRefreshSliverItem = Widget Function(BuildContext context, int index);

class EasyRefresh extends StatefulWidget {
  /// 下拉刷新回调
  final EasyRefreshCompere refresh;

  /// 下拉刷新状态变化距离
  final double refreshExtent;

  /// 下拉刷新自定义视图
  final EasyRefreshHeaderItem header;

  /// 上拉加载回调
  final EasyRefreshCompere load;

  /// 上拉加载状态变化距离
  final double loadExtent;

  /// 上拉加载自定义视图
  final EasyRefreshFooterItem footer;

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
  // 可滑动的最大距离
  double scrollMaxExtent = 0.0;
  // 下拉刷新state
  ValueNotifier<RefreshState> refreshStateNotifier;
  // 上拉加载state
  ValueNotifier<LoadState> loadStateNotifier;
  // header监听滑动距离
  ValueNotifier<double> headerOffsetNotifier;
  // footer监听滑动距离
  ValueNotifier<double> footerOffsetNotifier;

  @override
  void initState() {
    controller = ScrollController();
    refreshStateNotifier = ValueNotifier<RefreshState>(RefreshState.cancelRefresh);
    loadStateNotifier = ValueNotifier<LoadState>(LoadState.cancelLoad);
    headerOffsetNotifier = ValueNotifier<double>(0.0);
    footerOffsetNotifier = ValueNotifier<double>(0.0);
    super.initState();
  }

  @override
  void dispose() {
    if (controller != null) controller.dispose();
    if (headerOffsetNotifier != null) headerOffsetNotifier.dispose();
    if (footerOffsetNotifier != null) footerOffsetNotifier.dispose();
    if (refreshStateNotifier != null) refreshStateNotifier.dispose();
    if (loadStateNotifier != null) loadStateNotifier.dispose();
    super.dispose();
  }

  /// 手指离开屏幕时调用
  startRefresh(BuildContext context) {
    if (refreshStateNotifier.value == RefreshState.refreshing) return; // 防止多次点击
    if (controller.offset > -widget.refreshExtent) {
      refreshStateNotifier.value = RefreshState.cancelRefresh;
    } else {
      refreshStateNotifier.value = RefreshState.refreshing;
      if (widget.refresh != null) widget.refresh(context);
    }
  }

  /// 停止刷新回调
  stopRefresh() {
    refreshStateNotifier.value = RefreshState.cancelRefresh;
  }

  /// 滑动时更新state调用
  updateRefresh() {
    if (refreshStateNotifier.value == RefreshState.refreshing) return; // 如果在刷新中不改变刷新状态
    if (controller.offset > -widget.refreshExtent) {
      if (refreshStateNotifier.value == RefreshState.willRefresh) refreshStateNotifier.value = RefreshState.cancelRefresh;
    } else {
      if (refreshStateNotifier.value == RefreshState.cancelRefresh) refreshStateNotifier.value = RefreshState.willRefresh;
    }
  }

  /// 手指离开屏幕时调用
  startLoad(BuildContext context) {
    if (loadStateNotifier.value == LoadState.loading) return; // 防止多次点击
    if (controller.offset < scrollMaxExtent + widget.loadExtent) {
      loadStateNotifier.value = LoadState.cancelLoad;
    } else {
      loadStateNotifier.value = LoadState.loading;
      if (widget.load != null) widget.load(context);
    }
  }

  /// 停止加载回调
  stopLoad() {
    loadStateNotifier.value = LoadState.cancelLoad;
  }

  /// 停止加载回调
  stopLoadNoMore() {
    loadStateNotifier.value = LoadState.noMore;
  }

  /// 滑动时更新state调用
  updateLoad() {
    if (controller.offset < scrollMaxExtent + widget.loadExtent) {
      if (loadStateNotifier.value == LoadState.willLoad) loadStateNotifier.value = LoadState.cancelLoad;
    } else {
      if (loadStateNotifier.value == LoadState.cancelLoad) loadStateNotifier.value = LoadState.willLoad;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('--------------refresh build了--------------');
    return Builder(
      builder: (context) {
        return Listener(
          onPointerUp: (event) {
            // 监听手指抬起时
            if (controller.offset < 0.0 && widget.refresh != null) startRefresh(context);
            if (controller.offset > scrollMaxExtent && widget.load != null) startLoad(context);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollStartNotification) {
                // 保存最大滚动范围
                scrollMaxExtent = notification.metrics.maxScrollExtent;
              } else if (notification is ScrollUpdateNotification) {
                // 监听滑动距离
                if (controller.offset < 0.0 && widget.refresh != null) {
                  // 触发了下拉刷新
                  updateRefresh();
                  headerOffsetNotifier.value = controller.offset.abs();
                }else if (controller.offset > scrollMaxExtent && widget.load != null) {
                  // 触发了上拉加载
                  updateLoad();
                  footerOffsetNotifier.value = controller.offset-scrollMaxExtent;
                }
              }
              return true;
            },
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: controller,
              slivers: [
                EasyRefreshHeader(
                    offsetNotifier: headerOffsetNotifier,
                    refreshStateNotifier: refreshStateNotifier,
                    refreshExtent: widget.refreshExtent,
                    child: (context, offset) {
                      if (widget.header != null) return widget.header(context, refreshStateNotifier.value, offset);
                      return SizedBox();
                    }),
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
                    scrollMaxExtent: scrollMaxExtent,
                    offsetNotifier: footerOffsetNotifier,
                    loadStateNotifier: loadStateNotifier,
                    loadExtent: widget.loadExtent,
                    child: (context, offset) {
                      if (widget.footer != null) return widget.footer(context, loadStateNotifier.value, offset);
                      return SizedBox();
                    }),
              ],
            ),
          ),
        );
      },
    );
  }
}
