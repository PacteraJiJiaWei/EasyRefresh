import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'easy_refresh.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Container(
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
              child: EasyRefresh(
                refresh: (context) {
                  Future.delayed(Duration(seconds: 3), () {
                    EasyRefresh.of(context).stopRefresh();
                  });
                },
                load: (context) {
                  Future.delayed(Duration(seconds: 6), () {
                    EasyRefresh.of(context).stopLoad();
                  });
                },
                itemCount: 10,
                item: (context, index) {
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
                },
                footer: (context, loadState, offset) {
                  return Container(
                    height: 40.0,
                    padding: EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: loadState == LoadState.loading
                              ? CupertinoActivityIndicator(
                                  radius: 12,
                                )
                              : SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: CircularProgressIndicator(
                                    value: max(offset - 10.0, 0.0) / 30.0,
                                    strokeWidth: 2.0,
                                    backgroundColor: Colors.white,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                  ),
                                ),
                        ),
                        Text(
                          loadState == LoadState.loading
                              ? '正在加载哦'
                              : loadState == LoadState.willLoad ? '松手开始加载哦' : '上拉开始加载哦',
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                        ),
                      ],
                    ),
                  );
                },
                header: (context, refreshState, offset) {
                  return Container(
                    height: 60.0,
                    padding: EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: refreshState == RefreshState.refreshing
                              ? CupertinoActivityIndicator(
                                  radius: 12,
                                )
                              : SizedBox(
                                  height: 20.0,
                                  width: 20.0,
                                  child: CircularProgressIndicator(
                                    value: max(offset - 30.0, 0.0) / 30.0,
                                    strokeWidth: 2.0,
                                    backgroundColor: Colors.white,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                  ),
                                ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              refreshState == RefreshState.refreshing
                                  ? '正在刷新哦'
                                  : refreshState == RefreshState.willRefresh ? '松手开始刷新哦' : '下拉开始刷新哦',
                              style: TextStyle(fontSize: 14.0, color: Colors.black),
                            ),
                            Text(
                              'updateTime 9:00哦',
                              style: TextStyle(fontSize: 12.0, color: Colors.cyan),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
