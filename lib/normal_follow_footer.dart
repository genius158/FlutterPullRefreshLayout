import 'package:flutter/material.dart';

import 'pullrefreshlayout.dart';

/// 金色校园组件
class NormalFollowFooterWidget extends StatefulWidget {
  RefreshControl control;

  NormalFollowFooterWidget(this.control);

  @override
  NormalFollowFooterWidgetState createState() {
    return NormalFollowFooterWidgetState();
  }
}

class NormalFollowFooterWidgetState extends State<NormalFollowFooterWidget> {
  String text = "加载中";

  @override
  void initState() {
    super.initState();
    widget.control
        .addOnPullFinishCallback("NormalFooterWidget", onPullFinishCall);
  }

  @override
  Widget build(BuildContext context) {
    double height = 60;
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  void onPullFinishCall(RefreshControl control) {
    print("onPullFinishCall   " + control.isLoadingAble.toString());
    if (control.isLoadingProcess() && !control.isLoadingAble) {
      setState(() {
        text = "加载完毕";
      });
      print("onPullFinishCall   " + control.isLoadingAble.toString());
    }
  }
}
