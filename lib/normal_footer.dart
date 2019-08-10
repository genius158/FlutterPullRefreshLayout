import 'package:flutter/material.dart';

import 'pullrefreshlayout.dart';

/// 金色校园组件
class NormalFooterWidget extends StatefulWidget {
  RefreshControl control;

  NormalFooterWidget(this.control);

  @override
  NormalFooterWidgetState createState() {
    return NormalFooterWidgetState();
  }
}

class NormalFooterWidgetState extends State<NormalFooterWidget> {
  double dy = 0;
  String text = "加载中";

  @override
  void initState() {
    super.initState();
    widget.control.addOnPullChangeCallback("NormalFooterWidget", onPullChange);
    widget.control
        .addOnPullFinishCallback("NormalFooterWidget", onPullFinishCall);
    widget.control
        .addOnPullResetCallback("NormalFooterWidget", onPullResetCall);
  }

  @override
  Widget build(BuildContext context) {
    double height = 60;
    return Container(
      height: height,
      alignment: Alignment.center,
      child: Transform.translate(
        offset: Offset(0, height + dy),
        child: Text(
          text,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  void onPullChange(RefreshControl control, double offset) {
    if (control.isLoadingProcess()) {
      if (offset != 0) {
        setState(() {
          dy = -offset.abs();
        });
      }
    }
    print("setState   " +
        dy.toString() +
        "  " +
        control.refreshStatus.toString() +
        "  " +
        control.isLoadingProcess().toString());
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

  void onPullResetCall(RefreshControl control) {
    if (control.isLoadingProcess()) {
      setState(() {
        dy = -context.size.height;
      });
    } else if (control.isLoadingAble) {
      setState(() {
        text = "加载中";
      });
    }
  }
}
