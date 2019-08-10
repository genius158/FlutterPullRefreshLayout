import 'package:flutter/material.dart';

import 'normal_footer.dart';
import 'phoenix_header.dart';
import 'pullrefreshlayout.dart';

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

  ScrollPhysics _refreshLayoutPhysics =
//      new PullRefreshPhysics(parent: BouncingScrollPhysics());
      new PullRefreshPhysics();

  RefreshControl _control = new RefreshControl();
  int size = 0;

  @override
  Widget build(BuildContext context) {
    print("buildbuildbuildbuildbuildbuildbuildbuild");
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: PullRefreshLayout(
        control: _control,
        onInitialize: (control) => control.autoRefresh(),
        onPullHoldUnTrigger: (control) => print(
            "onPullHoldUnTrigger  " + control.isLoadingProcess().toString()),
        onPullHoldTrigger: (control) => print(
            "onPullHoldTrigger  " + control.isLoadingProcess().toString()),
        onPullFinish: (control) =>
            print("onPullFinish  " + control.isLoadingProcess().toString()),
        onPullReset: (control) =>
            print("onPullReset  " + control.isLoadingProcess().toString()),
        onPullHolding: (control) {
          Future.delayed(Duration(seconds: 1)).then((_) {
            if (control.isLoadingProcess()) {
              setState(() {
                size += 10;
              });
              control.finishLoading(complete: size > 10);
            } else {
              setState(() {
                size = 0;
                control.isLoadingAble = true;
              });
              control.finishRefresh();
            }
          });
        },
        refreshHeight: 100,
        header: PhoenixHeaderWidget(
          control: _control,
          height: 100,
        ),
//        header: Container(
//          color: Colors.red,
//          width: double.infinity,
//          height: 70,
//          child: Center(
//            child: InnerText(
//              _text,
//              style: TextStyle(
//                fontSize: 30,
//              ),
//            ),
//          ),
//        ),
        enableAutoLoading: true,
        loadingHeight: 70,
        footer: NormalFooterWidget(_control),
        child: getListTest(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  getListTest() {
    List widgets = List<Widget>();
    for (int i = 0; i < 20; i++) {
      widgets.add(
        InnerText(
          'InnerText $_counter',
          style: Theme.of(context).textTheme.display1,
        ),
      );
    }

    for (int i = 0; i < size; i++) {
      widgets.add(
        InnerText(
          'InnerText $_counter',
          style: Theme.of(context).textTheme.display1,
        ),
      );
    }

    return ListView(
      physics: _refreshLayoutPhysics,
      children: widgets,
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
                  child: new InnerText(
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
              child: InnerText('SliverGrid item $index'),
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
            child: new InnerText(
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
              child: InnerText('SliverFixedExtentList item $index'),
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
            child: new InnerText(
          'SliverGrid',
          style: new TextStyle(fontSize: 16),
        )),
      )),
    ];
    for (int i = 0; i < size; i++) {
      slivers.add(new SliverToBoxAdapter(
        child: new Visibility(
          child: new Container(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
            child: new Center(
              child: new InnerText("sdfsdf"),
            ),
          ),
        ),
      ));
    }
    return CustomScrollView(physics: _refreshLayoutPhysics, slivers: slivers);
  }

  Widget getNestTest() {
    ScrollController s;
    return CustomScrollView(
      physics: _refreshLayoutPhysics,
      slivers: <Widget>[
        const SliverAppBar(
          pinned: true,
          expandedHeight: 250.0,
          flexibleSpace: FlexibleSpaceBar(
            title: InnerText('Demo'),
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
                child: InnerText('grid item $index'),
              );
            },
            childCount: 20,
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 50.0,
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return Container(
                alignment: Alignment.center,
                color: Colors.lightBlue[100 * (index % 9)],
                child: InnerText('list item $index'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class InnerText extends StatelessWidget {
  final text;
  final style;

  const InnerText(this.text, {this.style});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 50,
        color: Colors.lightBlue,
        child: Text(
          text,
          style: style,
        ),
      ),
      onTap: () {
        showDialog(
            context: context,
            builder: (_) {
              return Container(
                width: double.infinity,
                child: Text("" + this.toString()),
                color: Colors.lightBlue,
              );
            });
      },
    );
  }
}
