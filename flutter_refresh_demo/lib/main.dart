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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
