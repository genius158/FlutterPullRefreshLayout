# flutter_pullrefreshlayout

PullRefreshLayout flutter 版本


### how to use 
```
// physics 物理参数需要包裹PullRefreshPhysics
// 如果你想改物理效果 可以设置 parent 参数,除了刷新阶段的物理，与你设置的parent一致
PullRefreshPhysics _refreshLayoutPhysics = new PullRefreshPhysics(parent);

child: PullRefreshLayout(
            onPullReset: (_) {
              setState(() {
                _text = "正常";
              });
            },
            onPullHoldUnTrigger: (_) {
              setState(() {
                _text = "不触发";
              });
            },
            onPullHoldTrigger: (_) {
              setState(() {
                _text = "触发";
              });
            },
            onPullHolding: (control) {
              setState(() {
                _text = "刷新";
              });
                Future.delayed(Duration(seconds: 2)).then((_) {
                control.finishRefresh();
                setState(() {
                  _text = "刷新完成";
                });
              });
            },
            header: Text(
              _text,
              style: TextStyle(fontSize: 40),
            ),
            child: ListView(
            // 想要保存状态，需要全局设置physics为PullRefreshPhysics
              physics: _refreshLayoutPhysics,
              children: <Widget>[
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.display1,
                ),
                ...
              ],
            ),
          ),

```