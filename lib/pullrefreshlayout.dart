import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'pullrefresharound.dart';
import 'pullrefreshlayoutphysics.dart';

class PullRefreshLayout extends StatefulWidget {
  final Widget child;
  final Widget header;
  final Widget footer;
  final OnInitializeCallback onInitialize;
  final OnPullChangeCallback onPullChange;
  final OnPullHoldTriggerCallback onPullHoldTrigger;
  final OnPullHoldUnTriggerCallback onPullHoldUnTrigger;
  final OnPullHoldingCallback onPullHolding;
  final OnPullResetCallback onPullReset;

  PullRefreshLayout(
      {Key key,
      @required this.child,
      this.header,
      this.footer,
      this.onInitialize,
      this.onPullChange,
      this.onPullHoldTrigger,
      this.onPullHoldUnTrigger,
      this.onPullHolding,
      this.onPullReset})
      : assert(child != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PullRefreshState();
  }
}

class _PullRefreshState extends State<PullRefreshLayout> {
  final GlobalKey _key = GlobalKey();

  StreamController<Object> _handleScroll;

  @override
  void dispose() {
    super.dispose();
    if (_handleScroll != null && !_handleScroll.isClosed) _handleScroll.close();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = new List();
    if (widget.header != null) {
      widgets.add(_Header(widget.header));
    }
    if (widget.footer != null) {
      widgets.add(_Footer(widget.footer));
    }
    widgets.add(widget.child);
    if (_handleScroll == null || _handleScroll.hasListener) {
      _handleScroll?.close();
      _handleScroll = new StreamController();
    }

    return NotificationListener<ScrollNotification>(
      key: _key,
      onNotification: (value) {
        _handleScroll.add(value);
      },
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (value) {
          if (!_handleScroll.isClosed) {
            _handleScroll.add(value);
          }
        },
        child: _PullRefreshWidget(
          widgets,
          _handleScroll.stream,
          widget.onInitialize,
          widget.onPullChange,
          widget.onPullHoldTrigger,
          widget.onPullHoldUnTrigger,
          widget.onPullHolding,
          widget.onPullReset,
        ),
      ),
    );
  }
}

class _PullRefreshWidget extends MultiChildRenderObjectWidget {
  final Stream<Object> _handleScroll;

  final OnInitializeCallback _onInitialize;
  final OnPullChangeCallback _onPullChange;
  final OnPullHoldTriggerCallback _onPullHoldTrigger;
  final OnPullHoldUnTriggerCallback _onPullHoldUnTrigger;
  final OnPullHoldingCallback _onPullHolding;
  final OnPullResetCallback _onPullReset;

  _PullRefreshWidget(
      List<Widget> children,
      this._handleScroll,
      this._onInitialize,
      this._onPullChange,
      this._onPullHoldTrigger,
      this._onPullHoldUnTrigger,
      this._onPullHolding,
      this._onPullReset)
      : super(children: children);

  @override
  MultiChildRenderObjectElement createElement() {
    return _PullRefreshElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return new _PullRefreshRender(
      _handleScroll,
      _onInitialize,
      _onPullChange,
      _onPullHoldTrigger,
      _onPullHoldUnTrigger,
      _onPullHolding,
      _onPullReset,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _PullRefreshRender renderObject) {
    renderObject
      ..streamHandle = _handleScroll
      ..onIniztialize = _onInitialize
      ..onPullChange = _onPullChange
      ..onPullHoldTrigger = _onPullHoldTrigger
      ..holdUnTrigger = _onPullHoldUnTrigger
      ..onPullHolding = _onPullHolding
      ..onPullReset = _onPullReset;
  }
}

class _PullRefreshRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _RefreshParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _RefreshParentData>,
        RefreshControl {
  Overflow _overflow = Overflow.clip;
  Stream<Object> _streamHandle;
  double _hScroll = 0;

  Element _scrollElement;

  RefreshStatus _refreshStatus = RefreshStatus.normal;
  int _eventStatus = 0;

  _WidgetRender _headerRender;
  _WidgetRender _footerRender;

  OnInitializeCallback _onInitialize;
  OnPullChangeCallback _onPullChange;
  OnPullHoldTriggerCallback _onPullHoldTrigger;
  OnPullHoldUnTriggerCallback _onPullHoldUnTrigger;
  OnPullHoldingCallback _onPullHolding;
  OnPullResetCallback _onPullFinish;

  void handleNotification(Notification value) {
    if (value is ScrollUpdateNotification) {
      _hScroll += value.scrollDelta;
      _headerRender?.translate(_hScroll);
      _footerRender?.translate(_hScroll);
    }
    if (value is OverscrollNotification) {
      if (_eventStatus == 2) {
        physics?.status(PhysicsStatus.bouncing);
      }
    } else if (value is UserScrollNotification) {
      if (value.direction == ScrollDirection.idle && _hScroll == 0) {
        onReset();
      }
    }
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerDownEvent) {
      if (_hScroll < 0) {
        physics?.status(PhysicsStatus.bouncing);
      } else {
        physics?.status(PhysicsStatus.normal);
      }
      _eventStatus = 1;
    } else if (event is PointerMoveEvent) {
      onMove();
      _eventStatus = 2;
    } else if (event is PointerCancelEvent || event is PointerUpEvent) {
      _eventStatus = 0;
      if (_hScroll >= scroller?.position?.minScrollExtent &&
          _hScroll <= scroller?.position?.maxScrollExtent) {
        physics?.scrollAble = true;
        physics?.status(PhysicsStatus.normal);
      }
      if (_hScroll < 0) {
        goRefresh();
      }
    }
  }

  void onMove() {
    if (_refreshStatus == RefreshStatus.reset ||
        _refreshStatus == RefreshStatus.holding) {
      return;
    }
    if (_hScroll < 0) {
      if (_hScroll <= -_headerRender?.size?.height) {
        if (_refreshStatus != RefreshStatus.holdTrigger &&
            _onPullHoldTrigger != null) {
          _refreshStatus = RefreshStatus.holdTrigger;
          _onPullHoldTrigger(this);
        }
      } else {
        if (_refreshStatus != RefreshStatus.holdUnTrigger &&
            _onPullHoldUnTrigger != null) {
          _refreshStatus = RefreshStatus.holdUnTrigger;
          _onPullHoldUnTrigger(this);
        }
      }
    }
  }

  void onReset() {
    physics?.status(PhysicsStatus.normal);
    physics.scrollAble = true;
    if (_refreshStatus == RefreshStatus.reset) {
      _refreshStatus = RefreshStatus.normal;
    }
  }

  void goRefresh() {
    physics.scrollAble = false;
    double to = -_headerRender?.size?.height;

    if (_refreshStatus == RefreshStatus.reset) {
      to = 0;
    } else {
      if (_refreshStatus == RefreshStatus.holding) {
        if (_hScroll > to) {
          to = _hScroll;
        }
      } else {
        if (_hScroll > to) {
          to = 0;
        }
      }
    }
    if (_hScroll == to) {
      return;
    }
    scroller
        ?.animateTo(to,
            duration: Duration(milliseconds: 400), curve: Curves.ease)
        ?.whenComplete(() {
      if (_hScroll == 0) {
        onReset();
      } else {
        bool next = _refreshStatus != RefreshStatus.reset &&
            _refreshStatus != RefreshStatus.holding;

        if (next) {
          _refreshStatus = RefreshStatus.holding;
          if (_onPullHolding != null) {
            _onPullHolding(this);
          }
        }
      }
    });
  }

  @override
  void autoRefresh() {}

  @override
  void finishRefresh() {
    _refreshStatus = RefreshStatus.reset;
    if (_onPullFinish != null) {
      _onPullFinish(this);
    }
    goRefresh();
  }

///////////////////////////////////分割线///////////////////////////////////////////

  set onIniztialize(onInitialize) => _onInitialize = onInitialize;

  set onPullChange(onPullChange) => _onPullChange = onPullChange;

  set onPullHoldTrigger(onPullHoldTrigger) =>
      _onPullHoldTrigger = onPullHoldTrigger;

  set holdUnTrigger(holdUnTrigger) => _onPullHoldUnTrigger = holdUnTrigger;

  set onPullHolding(onPullHolding) => _onPullHolding = onPullHolding;

  set onPullReset(onPullFinish) => _onPullFinish = onPullFinish;

  PullRefreshLayoutPhysics get physics {
    if (_scrollElement != null && _scrollElement.widget is Scrollable) {
      return (_scrollElement.widget as Scrollable).physics;
    }
    return null;
  }

  ScrollController get scroller {
    if (_scrollElement != null && _scrollElement.widget is Scrollable) {
      return (_scrollElement.widget as Scrollable).controller;
    }
    return null;
  }

  set scrollableElement(Element scrollElement) {
    _scrollElement = scrollElement;
  }

  set overFlow(Overflow overFlow) {
    if (overFlow != null) {
      _overflow = overFlow;
    }
  }

  set streamHandle(Stream<Object> streamHandle) {
    if (streamHandle != null) {
      _streamHandle = streamHandle;
      _streamHandle.listen((value) {
        if (value is Notification) {
          handleNotification(value);
        }
      });
    }
  }

///////////////////////////////////分割线///////////////////////////////////////////

  _PullRefreshRender(
      Stream<Object> handle,
      this._onInitialize,
      this._onPullChange,
      this._onPullHoldTrigger,
      this._onPullHoldUnTrigger,
      this._onPullHolding,
      this._onPullFinish,
      {List<RenderBox> children,
      Overflow clip}) {
    overFlow = clip;
    streamHandle = handle;
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    final ParentData childParentData = child.parentData;
    if (childParentData is! _RefreshParentData) {
      child.parentData = _RefreshParentData();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_overflow != Overflow.clip) {
      defaultPaint(context, offset);
    } else {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
      );
    }
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      return;
    }

    var child = firstChild;
    double layoutHeight = 0;
    while (child != null) {
      child.layout(constraints.loosen(), parentUsesSize: true);
      if (child is! _HeaderRender && child is! _FooterRender) {
        layoutHeight = child.size.height;
      }
      child = (child.parentData as _RefreshParentData).nextSibling;
    }
    child = firstChild;
    while (child != null) {
      final _RefreshParentData childParentData = child.parentData;
      if (child is _HeaderRender) {
        _headerRender = child;
        childParentData.offset = Offset(0, -child.size.height);
      } else if (child is _FooterRender) {
        _footerRender = child;
        childParentData.offset = Offset(0, layoutHeight);
      }
      child = childParentData.nextSibling;
    }

    size = constraints
        .tighten(
          height: layoutHeight,
        )
        .biggest;

    if (_onInitialize != null) {
      _onInitialize(this);
    }
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

class _PullRefreshElement extends MultiChildRenderObjectElement {
  _PullRefreshElement(MultiChildRenderObjectWidget widget) : super(widget);

  @override
  void mount(Element parent, newSlot) {
    super.mount(parent, newSlot);
    findScrollElement(this);
  }

  @override
  void update(MultiChildRenderObjectWidget newWidget) {
    super.update(newWidget);
    findScrollElement(this);
  }

  void findScrollElement(Element element) {
    if (element.widget is Scrollable) {
      _PullRefreshRender render = findRenderObject() as _PullRefreshRender;
      render.scrollableElement = element;
      return;
    }
    element.visitChildren(findScrollElement);
  }
}

class _RefreshParentData extends ContainerBoxParentData<RenderBox> {}

class _Header extends SingleChildRenderObjectWidget {
  const _Header(Widget child, {Key key}) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _HeaderRender();
  }
}

class _HeaderRender extends _WidgetRender {}

class _Footer extends SingleChildRenderObjectWidget {
  const _Footer(Widget child, {Key key}) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _FooterRender();
  }
}

class _FooterRender extends _WidgetRender {}

class _WidgetRender extends RenderProxyBox {
  _WidgetRender() : super(null);
  double _scroll;

  void translate(double scroll) {
    _scroll = scroll;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_scroll != null) {
      offset = offset.translate(0, -_scroll);
    }
    super.paint(context, offset);
  }
}
