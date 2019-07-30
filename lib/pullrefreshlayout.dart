import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'pullrefresharound.dart';
import 'pullrefreshphysics.dart';

class PullRefreshLayout extends StatefulWidget {
  final Widget child;
  final Widget header;
  final Widget footer;
  final OnInitializeCallback onInitialize;
  final OnPullChangeCallback onPullChange;
  final OnPullHoldTriggerCallback onPullHoldTrigger;
  final OnPullHoldUnTriggerCallback onPullHoldUnTrigger;
  final OnPullHoldingCallback onPullHolding;
  final OnPullFinishCallback onPullFinish;
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
      this.onPullFinish,
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
    widgets.add(widget.child);
    if (widget.header != null) {
      widgets.add(_Header(widget.header));
    }
    if (widget.footer != null) {
      widgets.add(_Footer(widget.footer));
    }

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
          widget.onPullFinish,
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
  final OnPullFinishCallback _onPullFinish;
  final OnPullResetCallback _onPullReset;

  _PullRefreshWidget(
      List<Widget> children,
      this._handleScroll,
      this._onInitialize,
      this._onPullChange,
      this._onPullHoldTrigger,
      this._onPullHoldUnTrigger,
      this._onPullHolding,
      this._onPullFinish,
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
      _onPullFinish,
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
      ..onPullFinish = _onPullFinish
      ..onPullReset = _onPullReset;
  }
}

class _PullRefreshRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _RefreshParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _RefreshParentData>,
        RefreshControl {
  /// 滚动事件分发
  Stream<Object> _streamHandle;

  ///是否剪切
  Overflow _overflow = Overflow.clip;

  /// scrollable 的element
  Element _scrollElement;

  /// 当前刷新状态
  RefreshStatus _refreshStatus = RefreshStatus.normal;

  /// 处在刷新过程中
  bool _isRefreshProcess = false;

  /// 处在加载过程中
  bool _isLoadingProcess = false;

  /// 是否是由触摸引起的滑动
  bool _isTouchMoving = false;

  /// 总共的滑动距离
  double _hScroll = 0;

  /// 当前滑动偏移量
  double _offset = 0;

  /// 头部渲染器
  _WidgetRender _headerRender;

  /// 底部渲染器
  _WidgetRender _footerRender;

  OnInitializeCallback _onInitialize;
  OnPullChangeCallback _onPullChange;
  OnPullHoldTriggerCallback _onPullHoldTrigger;
  OnPullHoldUnTriggerCallback _onPullHoldUnTrigger;
  OnPullHoldingCallback _onPullHolding;
  OnPullFinishCallback _onPullFinish;
  OnPullResetCallback _onPullReset;

  void handleNotification(Notification value) {
    if (value is ScrollUpdateNotification) {
      _hScroll += _offset = value.scrollDelta;
      if (!isScrollNormal) {
        _onMoving();
      }
      _headerRender?.translate(_hScroll);

      double offset = _hScroll - maxScrollExtent ?? _hScroll;
      offset = offset > 0 ? offset : 0;
      _footerRender?.translate(offset);
    }
    if (value is OverscrollNotification) {
      OverscrollNotification over = value;
      if (_isTouchMoving) {
        if (hasHeader && over.overscroll < 0 ||
            hasFooter && over.overscroll > 0) {
          physics?.status(PhysicsStatus.bouncing);
        }
      }
    } else if (value is UserScrollNotification) {
      if (value.direction == ScrollDirection.idle && isScrollNormal) {
        _tryReset();
      }
    }
  }

  /// 判断是否还有touch事件
  int _touchFlag = 0;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    if (event is PointerDownEvent) {
      _touchFlag++;
      if (isScrollNormal) {
        physics?.status(PhysicsStatus.normal);
      }
    } else if (event is PointerMoveEvent) {
      _isTouchMoving = true;
    } else if (event is PointerCancelEvent || event is PointerUpEvent) {
      _touchFlag--;
      if (_touchFlag > 0) {
        return;
      }
      _isTouchMoving = false;
      if (isScrollNormal) {
        physics?.scrollAble = true;
        physics?.status(PhysicsStatus.normal);
      } else {
        goRefresh();
      }
    }
  }

  void _onMoving() {
    if (_onPullChange != null) {
      double present = 0;
      if (hasHeader && isOverTop) {
        present = (_hScroll - minScrollExtent) / headerHeight;
        _onPullChange(this, present);
      } else if (hasFooter && isOverBottom) {
        present = (_hScroll - maxScrollExtent) / footerHeight;
        _onPullChange(this, present);
      }
    }

    if (_isRefreshProcess || _isLoadingProcess) {
      return;
    }

    triggerLogic(bool type, bool holdTriggerGo) {
      if (type) {
        if (_refreshStatus != RefreshStatus.holdTrigger &&
            _onPullHoldTrigger != null &&
            // 只有在触摸的情况下，才走恢复到触发的逻辑逻辑
            (holdTriggerGo && _isTouchMoving)) {
          _refreshStatus = RefreshStatus.holdTrigger;
          _onPullHoldTrigger(this);
        }
      } else if (_refreshStatus != RefreshStatus.holdUnTrigger &&
          _onPullHoldUnTrigger != null) {
        _refreshStatus = RefreshStatus.holdUnTrigger;
        _onPullHoldUnTrigger(this);
      }
    }

    if (isOverTop) {
      triggerLogic(isUnBelowRefreshExtend, _offset < 0);
    } else if (isOverBottom) {
      triggerLogic(isUnBelowLoadingExtend, _offset > 0);
    }
  }

  void _tryReset() {
    if (_refreshStatus == RefreshStatus.reset) {
      physics?.status(PhysicsStatus.normal);
      physics?.scrollAble = true;
      _refreshStatus = RefreshStatus.normal;
      _isRefreshProcess = false;
      _isLoadingProcess = false;
      if (_onPullReset != null) {
        _onPullReset(this);
      }

      _footerRender?.translate(_hScroll);
      _headerRender?.translate(_hScroll);
    }
  }

  void goRefresh() {
    physics?.scrollAble = false;

    double to = _hScroll;
    if (!isScrollNormal) {
      if (isOverTop) {
        to = isUnBelowRefreshExtend ? refreshScrollExtent : minScrollExtent;
      } else if (isOverBottom) {
        to = isUnBelowLoadingExtend ? loadingScrollExtent : maxScrollExtent;
      }
    }

    if (_refreshStatus == RefreshStatus.reset) {
      if (isScrollNormal) {
        _tryReset();
        return;
      }
      to = isOverTop ? minScrollExtent : maxScrollExtent;
    } else {
      if (_refreshStatus == RefreshStatus.holding) {
        if (isOverTop && _isRefreshProcess) {
          if (!isUnBelowRefreshExtend) {
            return;
          }
        } else if (isOverBottom && _isLoadingProcess) {
          if (!isUnBelowLoadingExtend) {
            return;
          }
        }
      }
    }

    if (isScrollNormal) {
      _onRefreshLogic();
    } else {
      scroller
          ?.animateTo(to,
              duration: Duration(milliseconds: animationDuring),
              curve: Curves.ease)
          ?.whenComplete(() {
        _onRefreshLogic();
      });
    }
  }

  void _onRefreshLogic() {
    if (isScrollNormal) {
      _tryReset();
      return;
    }
    if (_isRefreshProcess || _isLoadingProcess) {
      return;
    }
    bool isTrigger = false;
    if (isUnBelowRefreshExtend) {
      isTrigger = _isRefreshProcess = true;
    } else if (isUnBelowLoadingExtend) {
      isTrigger = _isLoadingProcess = true;
    }
    if (isTrigger) {
      _refreshStatus = RefreshStatus.holding;
      if (_onPullHolding != null) {
        _onPullHolding(this);
      }
    }
  }

  @override
  bool isRefresh() {
    return _isRefreshProcess;
  }

  @override
  bool isLoadMore() {
    return _isLoadingProcess;
  }

  @override
  void autoRefresh({int delay: 300}) {
    if (!hasHeader) {
      return;
    }
    auto() {
      physics?.scrollAble = false;
      physics?.status(PhysicsStatus.bouncing);
      scroller
          ?.animateTo(refreshScrollExtent,
              duration: Duration(milliseconds: animationDuring),
              curve: Curves.ease)
          ?.whenComplete(() {
        _onRefreshLogic();
      });
    }

    if (delay == 0) {
      auto();
    } else {
      Future.delayed(Duration(milliseconds: delay)).then((_) {
        auto();
      });
    }
  }

  @override
  void finish({int delay: 300}) {
    finish() {
      _refreshStatus = RefreshStatus.reset;
      if (_onPullFinish != null) {
        _onPullFinish(this);
      }
      goRefresh();
    }

    if (delay == 0) {
      finish();
    } else {
      Future.delayed(Duration(milliseconds: delay)).then((_) {
        finish();
      });
    }
  }

///////////////////////////////////分割线///////////////////////////////////////////

  set onIniztialize(onInitialize) => _onInitialize = onInitialize;

  set onPullChange(onPullChange) => _onPullChange = onPullChange;

  set onPullHoldTrigger(onPullHoldTrigger) =>
      _onPullHoldTrigger = onPullHoldTrigger;

  set holdUnTrigger(holdUnTrigger) => _onPullHoldUnTrigger = holdUnTrigger;

  set onPullHolding(onPullHolding) => _onPullHolding = onPullHolding;

  set onPullFinish(onPullFinish) => _onPullFinish = onPullFinish;

  set onPullReset(onPullReset) => _onPullReset = onPullReset;

  bool get isOverTop => _hScroll < minScrollExtent ?? _hScroll;

  bool get isOverBottom => _hScroll > maxScrollExtent ?? _hScroll;

  bool get hasHeader => _headerRender != null;

  bool get hasFooter => _footerRender != null;

  double get refreshScrollExtent => -headerHeight + minScrollExtent ?? _hScroll;

  double get loadingScrollExtent => footerHeight + maxScrollExtent ?? _hScroll;

  /// 当前位置是否可以触发下拉刷新
  bool get isUnBelowRefreshExtend =>
      hasHeader ? _hScroll <= refreshScrollExtent : false;

  /// 当前位置是否可以触发上拉加载
  bool get isUnBelowLoadingExtend =>
      hasFooter ? _hScroll >= loadingScrollExtent : false;

  double get minScrollExtent => scroller?.position?.minScrollExtent;

  double get maxScrollExtent => scroller?.position?.maxScrollExtent;

  int animationDuring = 400;

  double get headerHeight {
    if (_headerRender != null) {
      return _headerRender.size.height;
    }
    return 0;
  }

  double get footerHeight {
    if (_footerRender != null) {
      return _footerRender.size.height;
    }
    return 0;
  }

  /// 是否处在正常滚动范围（不出在isOverTop、isOverBottom状态）
  bool get isScrollNormal =>
      (minScrollExtent ?? _hScroll) <= _hScroll &&
      _hScroll <= (maxScrollExtent ?? _hScroll);

  PullRefreshPhysics get physics {
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
      this._onPullReset,
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
    _headerRender = null;
    _footerRender = null;

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
    if (_scroll == scroll) {
      return;
    }
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
