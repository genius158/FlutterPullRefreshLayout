import 'package:flutter/material.dart';
import 'package:flutter_pullrefreshlayout/pullrefreshlayout.dart';

import 'pullrefreshphysics.dart';

//void main() => Future.delayed(Duration(seconds: 5)).then((_) {
//      runApp(MyApp());
//    });

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in a Flutter IDE). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  PullRefreshPhysics _refreshLayoutPhysics = new PullRefreshPhysics();
  String _text = "正常";
  int size = 0;
  bool firstShowFlag = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: PullRefreshLayout(
          onInitialize: (control) {
            if (firstShowFlag) {
              firstShowFlag = false;
              control.autoRefresh();
            }
          },
          onPullChange: (_, value) {},
          onPullFinish: (_) {},
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
              _text = control.isRefresh() ? "正在刷新" : "正在加载";
            });
            Future.delayed(Duration(seconds: 3)).then((_) {
              setState(() {
                if (control.isLoadMore()) {
                  _text = "加载完成";
                  size += 10;
                } else {
                  _text = "刷新完成";
                }
              });
              control.finish();
            });
          },
          header: Container(
            color: Colors.red,
            width: double.infinity,
            height: 50,
            child: Center(
              child: Text(
                _text,
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ),
          ),
          child: getScrollTest(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  getListTest() {
    return ListView(
      physics: _refreshLayoutPhysics,
      children: <Widget>[
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '$_counter',
          style: Theme.of(context).textTheme.display1,
        ),
      ],
    );
  }

  getScrollTest() {
    List<Widget> slivers = [
      new SliverToBoxAdapter(
        child: new Container(
          color: Colors.lightBlue,
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: new Column(
            children: <Widget>[
              new SizedBox(
                  child: new Text(
                'SliverGrid',
                style: new TextStyle(fontSize: 16),
              )),
              new Divider(
                color: Colors.grey,
                height: 20,
              )
            ],
          ),
        ),
      ),
      SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 4.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Container(
              alignment: Alignment.center,
              color: Colors.teal[100 * (index % 9)],
              child: Text('SliverGrid item $index'),
            );
          },
          childCount: 10,
        ),
      ),
      new SliverToBoxAdapter(
          child: new Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        color: Colors.green,
        child: new SizedBox(
            child: new Text(
          'SliverFixedExtentList',
          style: new TextStyle(fontSize: 16),
        )),
      )),
      SliverFixedExtentList(
        itemExtent: 50.0,
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Container(
              alignment: Alignment.center,
              color: Colors.lightBlue[100 * (index % 9)],
              child: Text('SliverFixedExtentList item $index'),
            );
          },
          childCount: 20,
        ),
      ),
      new SliverToBoxAdapter(
          child: new Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        color: Colors.green,
        child: new SizedBox(
            child: new Text(
          'SliverGrid',
          style: new TextStyle(fontSize: 16),
        )),
      )),
      SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 4.0,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Container(
              alignment: Alignment.center,
              color: Colors.teal[100 * (index % 9)],
              child: Text('SliverGrid item2 $index'),
            );
          },
          childCount: 20,
        ),
      ),
      new SliverToBoxAdapter(
        child: new Visibility(
          child: new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: new Center(
              child: new Text("sdfsdf"),
            ),
          ),
        ),
      ),
    ];
    for (int i = 0; i < size; i++) {
      slivers.add(new SliverToBoxAdapter(
        child: new Visibility(
          child: new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: new Center(
              child: new Text("sdfsdf"),
            ),
          ),
        ),
      ));
    }
    return CustomScrollView(physics: _refreshLayoutPhysics, slivers: slivers);
  }
}
