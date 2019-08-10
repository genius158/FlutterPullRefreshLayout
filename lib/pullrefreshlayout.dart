import 'dart:async';
import 'dart:collection';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

import 'pullrefresharound.dart';
import 'pullrefreshphysics.dart';

export 'pullrefresharound.dart';
export 'pullrefreshphysics.dart';

class PullRefreshLayout extends StatefulWidget {
  final Widget child;
  final Widget header;
  final Widget footer;
  final double refreshHeight;
  final double loadingHeight;
  final bool enableAutoLoading;
  final IndicatorStatus headerStatus;
  final IndicatorStatus footerStatus;

  final OnInitializeCallback onInitialize;
  final OnPullChangeCallback onPullChange;
  final OnPullHoldTriggerCallback onPullHoldTrigger;
  final OnPullHoldUnTriggerCallback onPullHoldUnTrigger;
  final OnPullHoldingCallback onPullHolding;
  final OnPullFinishCallback onPullFinish;
  final OnPullResetCallback onPullReset;
  final RefreshControl control;

  PullRefreshLayout({
    Key key,
    @required this.child,
    this.header,
    this.footer,
    this.refreshHeight,
    this.loadingHeight,
    this.enableAutoLoading: false,
    this.onInitialize,
    this.onPullChange,
    this.onPullHoldTrigger,
    this.onPullHoldUnTrigger,
    this.onPullHolding,
    this.onPullFinish,
    this.onPullReset,
    this.control,
    this.headerStatus: IndicatorStatus.fixed,
    this.footerStatus: IndicatorStatus.fixed,
  })  : assert(child != null),
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
    if (widget.header != null) widgets.add(_Header(widget.header));
    if (IndicatorStatus.follow == widget.footerStatus) {
      widgets.add(_Content(widget.child));
      if (widget.footer != null) widgets.add(_Footer(widget.footer));
    } else {
      if (widget.footer != null) widgets.add(_Footer(widget.footer));
      widgets.add(_Content(widget.child));
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
          widget.refreshHeight,
          widget.loadingHeight,
          widget.enableAutoLoading,
          widget.onInitialize,
          widget.onPullChange,
          widget.onPullHoldTrigger,
          widget.onPullHoldUnTrigger,
          widget.onPullHolding,
          widget.onPullFinish,
          widget.onPullReset,
          widget.control,
          widget.headerStatus,
          widget.footerStatus,
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
  final RefreshControl _control;
  final IndicatorStatus _headerStatus;
  final IndicatorStatus _footerStatus;

  final double _refreshHeight;
  final double _loadingHeight;

  final bool _enableAutoLoading;

  _PullRefreshWidget(
    List<Widget> children,
    this._handleScroll,
    this._refreshHeight,
    this._loadingHeight,
    this._enableAutoLoading,
    this._onInitialize,
    this._onPullChange,
    this._onPullHoldTrigger,
    this._onPullHoldUnTrigger,
    this._onPullHolding,
    this._onPullFinish,
    this._onPullReset,
    this._control,
    this._headerStatus,
    this._footerStatus,
  ) : super(children: children);

  @override
  MultiChildRenderObjectElement createElement() {
    return _PullRefreshElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return new _PullRefreshRender(
      _handleScroll,
      _refreshHeight,
      _loadingHeight,
      _enableAutoLoading,
      _onInitialize,
      _onPullChange,
      _onPullHoldTrigger,
      _onPullHoldUnTrigger,
      _onPullHolding,
      _onPullFinish,
      _onPullReset,
      _control,
      _headerStatus,
      _footerStatus,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _PullRefreshRender renderObject) {
    renderObject
      ..streamHandle = _handleScroll
      ..refreshHeight = _refreshHeight
      ..loadingHeight = _loadingHeight
      .._enableAutoLoading = _enableAutoLoading
      ..onInitialize = _onInitialize
      ..onPullChange = _onPullChange
      ..onPullHoldTrigger = _onPullHoldTrigger
      ..onPullHoldUnTrigger = _onPullHoldUnTrigger
      ..onPullHolding = _onPullHolding
      ..onPullFinish = _onPullFinish
      ..onPullReset = _onPullReset
      .._headerStatus = _headerStatus
      .._footerStatus = _footerStatus;
  }
}

class _PullRefreshRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _RefreshParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _RefreshParentData>,
        RefreshControl,
        RefreshData {
  static const String _TAG = "AA_PRL_DEFAULT_TAG";

  /// 滚动事件分发
  Stream<Object> _streamHandle;

  ///是否剪切
  Overflow _overflow = Overflow.clip;

  /// 滚动控制器
  ScrollController _scroller;

  RenderViewport _renderViewport;

  /// 当前刷新状态
  RefreshStatus _refreshStatus = RefreshStatus.normal;

  /// 处在刷新过程中
  bool _isRefreshProcess = false;

  /// 处在加载过程中
  bool _isLoadingProcess = false;

  /// 是否是由触摸引起的滑动
  bool _isTouchMoving = false;

  /// 当前滑动偏移量
  double _offset = 0;

  /// 头部渲染器
  _HeaderRender _headerRender;

  /// 底部渲染器
  _FooterRender _footerRender;

  /// 是否要开始刷新
  bool _isToRefreshHolding = false;

  /// 是否要开始加载
  bool _isToLoadingHolding = false;

  /// 刷新过程动画时间
  int animationDuring = 400;

  /// 刷新高度
  double _refreshHeight;

  /// 加载高度
  double _loadingHeight;

  /// 自动加载是否可用
  bool _enableAutoLoading;

  bool _isRefreshAble = true;
  bool _isLoadingAble = true;
  bool _isFooterKeep = true;

  RefreshControl _refreshControl;
  IndicatorStatus _headerStatus;
  IndicatorStatus _footerStatus;

  LinkedHashMap<String, OnInitializeCallback> _onInitializes = LinkedHashMap();
  LinkedHashMap<String, OnPullChangeCallback> _onPullChanges = LinkedHashMap();
  LinkedHashMap<String, OnPullHoldTriggerCallback> _onPullHoldTriggers =
      LinkedHashMap();
  LinkedHashMap<String, OnPullHoldUnTriggerCallback> _onPullHoldUnTriggers =
      LinkedHashMap();
  LinkedHashMap<String, OnPullHoldingCallback> _onPullHoldings =
      LinkedHashMap();
  LinkedHashMap<String, OnPullFinishCallback> _onPullFinishes = LinkedHashMap();
  LinkedHashMap<String, OnPullResetCallback> _onPullResets = LinkedHashMap();

  void _translate() {
    bool needRelayout = false;
    if (isScrollNormal) {
      _headerRender.offstage = true;
      _footerRender.offstage = true;
    } else {
      if (isOverTop) {
        _headerRender.offstage = false;
      } else if (isOverBottom) {
        _footerRender.offstage = false;
      }
      needRelayout = true;
    }
    if (needRelayout) markNeedsLayout();
  }

  void handleNotification(Notification value) {
    if (value is ScrollNotification) {
      if (value.metrics.axis == Axis.horizontal) {
        return;
      }
    }
    if (value is ScrollUpdateNotification) {
      _offset = value.scrollDelta;
      _statusMoveEndNormal();
      _onMoving();
      _translate();
    }
    if (value is OverscrollNotification) {
      OverscrollNotification over = value;
      if (_isTouchMoving) {
        if (!_isToLoadingHolding && isRefreshAble && over.overscroll < 0 ||
            !_isToRefreshHolding && isLoadingAble && over.overscroll > 0) {
          physics?.status = PhysicsStatus.bouncing;
        }
      }
    } else if (value is UserScrollNotification) {
      if (value.direction == ScrollDirection.idle &&
          (isScrollNormal || enableAutoLoading && !isOverTop)) {
        _tryReset();
      }
    }
  }

  final Map<int, VelocityTracker> _velocityTrackers = <int, VelocityTracker>{};

  void _velocityTrack(PointerEvent event) {
    if (event is PointerCancelEvent || event is PointerUpEvent) {
      return;
    }
    if (_velocityTrackers[event.pointer] == null) {
      _velocityTrackers[event.pointer] = VelocityTracker();
    } else {
      final VelocityTracker tracker = _velocityTrackers[event.pointer];
      tracker.addPosition(event.timeStamp, event.position);
    }
  }

  /// 判断是否还有touch事件
  int _touchFlag = 0;

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    _velocityTrack(event);
    if (event is PointerDownEvent) {
      physics?.scrollAble = true;
      _touchFlag++;
      if (isScrollNormal) physics?.status = PhysicsStatus.normal;
    } else if (event is PointerMoveEvent) {
      _isTouchMoving = true;
    } else if (event is PointerCancelEvent || event is PointerUpEvent) {
      _touchFlag--;
      if (_touchFlag > 0) return;
      _isTouchMoving = false;
      if (isScrollNormal) {
        physics?.scrollAble = true;
        physics?.status = PhysicsStatus.normal;
      } else {
        endTouchLogic(event);
      }
    }
  }

  void _tryHolding({bool toHolding}) {
    /// 是否执行动画
    bool animate = true;
    if (!_isRefreshProcess && !_isLoadingProcess) {
      animate = isRefreshAble;

      /// 刷新可用同时处在可触发刷新的位置
      if (animate && isUnBelowRefreshExtend) {
        _isToRefreshHolding = true;
      } else {
        animate = isLoadingAble;

        bool hold = toHolding ?? isUnBelowLoadingExtend;

        /// 加载可用同时处在可触发加载的位置
        if (animate && hold) {
          if (animate) _isToLoadingHolding = true;
        }
      }
      if (_isToRefreshHolding || _isToLoadingHolding) {
        _refreshStatus = RefreshStatus.holding;
        _onPullHolding();
      }
    }
    if (animate) _animate2Status();
  }

  void endTouchLogic(PointerEvent event) {
    final VelocityTracker tracker = _velocityTrackers[event.pointer];
    final VelocityEstimate estimate = tracker.getVelocityEstimate();
    if (estimate != null && estimate.pixelsPerSecond != null) {
      final double minVelocity = physics?.minFlingVelocity ?? kMinFlingVelocity;
      final double minDistance = physics?.minFlingDistance ?? kTouchSlop;
      bool isFlingGesture = estimate.pixelsPerSecond.dy.abs() > minVelocity &&
          estimate.offset.dy.abs() > minDistance;
      if (estimate != null && isFlingGesture) {
        Simulation bouncing = BouncingScrollSimulation(
          spring: physics?.spring,
          position: curPixels,
          velocity: -estimate.pixelsPerSecond.dy * 0.91,
          leadingExtent: double.negativeInfinity,
          trailingExtent: double.infinity,
          tolerance: physics?.tolerance,
        );
        double endScrollY = bouncing.x(double.infinity);
        if (isOverTop && endScrollY < (minScrollExtent - curPixels) * 2 ||
            isOverBottom && endScrollY > (curPixels - maxScrollExtent) * 2) {
          _tryHolding();
        }
      } else {
        _tryHolding();
      }
    } else {
      _tryHolding();
    }
  }

  void _onMoving() {
    autoLoading() {
      if (!_isToLoadingHolding &&
          !_isToRefreshHolding &&
          enableAutoLoading &&
          _offset > 0) {
        bool toHolding = curPixels + _offset >= maxScrollExtent;
        if (toHolding) _tryHolding(toHolding: toHolding);
      }
    }

    if (isScrollNormal) {
      _onPullChange(0);
      autoLoading();
      return;
    }
    autoLoading();
    if (isOverTop) {
      _onPullChange((curPixels - minScrollExtent));
    } else if (isOverBottom) {
      _onPullChange((curPixels - maxScrollExtent));
    }
    if (_isToRefreshHolding || _isToLoadingHolding) return;

    trigger(bool type, bool holdTriggerGo) {
      if (type) {
        if (_refreshStatus != RefreshStatus.holdTrigger &&
            // 只有在触摸的情况下，才走恢复到触发的逻辑逻辑
            (holdTriggerGo && _isTouchMoving)) {
          _refreshStatus = RefreshStatus.holdTrigger;
          _onPullHoldTrigger();
        }
      } else if (_refreshStatus != RefreshStatus.holdUnTrigger) {
        _refreshStatus = RefreshStatus.holdUnTrigger;
        _onPullHoldUnTrigger();
      }
    }

    if (isOverTop && isRefreshAble) {
      trigger(isUnBelowRefreshExtend, _offset < 0);
    } else if (isOverBottom && isLoadingAble) {
      trigger(isUnBelowLoadingExtend, _offset > 0);
    }
  }

  void _tryReset() {
    if (_refreshStatus == RefreshStatus.reset) {
      _onPullReset();
      _refreshStatus = RefreshStatus.normal;
      physics?.scrollAble = true;
      physics?.status = PhysicsStatus.normal;

      _isToRefreshHolding = false;
      _isToLoadingHolding = false;
      _isRefreshProcess = false;
      _isLoadingProcess = false;
      _translate();
    }
  }

  void _animate2Status() {
    double to = curPixels;
    if (refreshStatus == RefreshStatus.holding &&
        (_isRefreshProcess || _isLoadingProcess)) {
      return;
    } else if (_refreshStatus == RefreshStatus.reset) {
      if (isScrollNormal) {
        _tryReset();
        return;
      }
      to = isOverTop ? minScrollExtent : maxScrollExtent;
    } else {
      if (!isScrollNormal) {
        if (isOverTop) {
          to = minScrollExtent;
          if (!_isToLoadingHolding && isUnBelowRefreshExtend)
            to = refreshScrollExtent;
        } else if (isOverBottom) {
          to = maxScrollExtent;
          if (!_isToRefreshHolding && isUnBelowLoadingExtend)
            to = loadingScrollExtent;
        }
      }
    }
    holdFlag() {
      if (_isRefreshProcess || _isLoadingProcess) {
        return false;
      }
      if (_isToRefreshHolding) {
        return _isRefreshProcess = true;
      } else if (_isToLoadingHolding) {
        return _isLoadingProcess = true;
      }
      return false;
    }

    if (isScrollNormal || !isOverTop && enableAutoLoading) {
      if (!holdFlag()) {
        _tryReset();
      }
    } else {
      if (holdFlag()) {
        return;
      }
      physics?.scrollAble = false;
      _scroller
          ?.animateTo(to,
              duration: Duration(milliseconds: animationDuring),
              curve: Curves.linearToEaseOut)
          ?.whenComplete(() {
        if (_isRefreshProcess || _isLoadingProcess) {
          if (isScrollNormal && _refreshStatus == RefreshStatus.reset) {
            _tryReset();
          }
          return;
        }
        holdFlag();
      });
    }
  }

  @override
  bool isRefreshProcess() =>
      _isToRefreshHolding || isOverTop && !_isToLoadingHolding;

  @override
  bool isLoadingProcess() =>
      _isToLoadingHolding || isOverBottom && !_isToRefreshHolding;

  bool get isToRefreshHolding => _isToRefreshHolding;

  bool get isToLoadingHolding => _isToLoadingHolding;

  @override
  void autoRefresh({int delay: 300}) {
    auto() {
      if (_isRefreshProcess || _isLoadingProcess || !isRefreshAble) return;
      _isToRefreshHolding = true;
      physics?.scrollAble = false;
      physics?.status = PhysicsStatus.bouncing;
      _scroller
          ?.animateTo(refreshScrollExtent,
              duration: Duration(milliseconds: animationDuring),
              curve: Curves.linearToEaseOut)
          ?.whenComplete(() {
        _tryHolding();
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
  void finishRefresh({int delay: 300, bool complete: false}) {
    if (!isRefreshAble) {
      return;
    }
    _isRefreshAble = !complete;
    _finish(delay);
  }

  @override
  void finishLoading({int delay: 300, bool complete: false, bool keep: true}) {
    _isFooterKeep = keep;
    if (!isLoadingAble) {
      return;
    }
    _isLoadingAble = !complete;
    _finish(delay);
  }

  void _finish(int delay) {
    finish() {
      _onPullFinish();
      _refreshStatus = RefreshStatus.reset;
      _animate2Status();
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
  void addOnInitializeCallback(
      String callbackName, OnInitializeCallback onInitializeCall) {
    if (onInitializeCall != null)
      _onInitializes[callbackName] = onInitializeCall;
  }

  void addOnPullChangeCallback(
      String callbackName, OnPullChangeCallback onPullChangeCall) {
    if (onPullChangeCall != null)
      _onPullChanges[callbackName] = onPullChangeCall;
  }

  void addOnPullHoldTriggerCallback(
      String callbackName, OnPullHoldTriggerCallback onPullHoldTriggerCall) {
    if (onPullHoldTriggerCall != null)
      _onPullHoldTriggers[callbackName] = onPullHoldTriggerCall;
  }

  void addOnPullHoldUnTriggerCallback(String callbackName,
      OnPullHoldUnTriggerCallback onPullHoldUnTriggerCall) {
    if (onPullHoldUnTriggerCall != null)
      _onPullHoldUnTriggers[callbackName] = onPullHoldUnTriggerCall;
  }

  void addOnPullHoldingCallback(
      String callbackName, OnPullHoldingCallback onPullHoldingCall) {
    if (onPullHoldingCall != null)
      _onPullHoldings[callbackName] = onPullHoldingCall;
  }

  void addOnPullFinishCallback(
      String callbackName, OnPullFinishCallback onPullFinishCall) {
    if (onPullFinishCall != null)
      _onPullFinishes[callbackName] = onPullFinishCall;
  }

  void addOnPullResetCallback(
      String callbackName, OnPullResetCallback onPullResetCall) {
    if (onPullResetCall != null) _onPullResets[callbackName] = onPullResetCall;
  }

  set onInitialize(onInitialize) => addOnInitializeCallback(_TAG, onInitialize);

  set onPullChange(onPullChange) => addOnPullChangeCallback(_TAG, onPullChange);

  set onPullHoldTrigger(onPullHoldTrigger) =>
      addOnPullHoldTriggerCallback(_TAG, onPullHoldTrigger);

  set onPullHoldUnTrigger(onPullHoldUnTrigger) =>
      addOnPullHoldUnTriggerCallback(_TAG, onPullHoldUnTrigger);

  set onPullHolding(onPullHolding) =>
      addOnPullHoldingCallback(_TAG, onPullHolding);

  set onPullFinish(onPullFinish) => addOnPullFinishCallback(_TAG, onPullFinish);

  set onPullReset(onPullReset) => addOnPullResetCallback(_TAG, onPullReset);

  bool get isOverTop =>
      curPixels < (minScrollExtent == null ? curPixels : minScrollExtent);

  bool get isOverBottom =>
      curPixels > (maxScrollExtent == null ? curPixels : maxScrollExtent);

  bool get isRefreshAble => _headerRender != null && _isRefreshAble;

  bool get isLoadingAble => _footerRender != null && _isLoadingAble;

  set isRefreshAble(bool refreshAble) => _isRefreshAble = refreshAble;

  set isLoadingAble(bool loadingAble) => _isLoadingAble = loadingAble;

  @override
  double get refreshScrollExtent =>
      -refreshHeight + (minScrollExtent == null ? curPixels : minScrollExtent);

  @override
  double get loadingScrollExtent =>
      loadingHeight + (maxScrollExtent == null ? curPixels : maxScrollExtent);

  double get getScrollPixel => curPixels;

  /// 当前位置是否可以触发下拉刷新
  bool get isUnBelowRefreshExtend =>
      isRefreshAble ? curPixels <= refreshScrollExtent : false;

  /// 当前位置是否可以触发上拉加载
  bool get isUnBelowLoadingExtend =>
      isLoadingAble ? curPixels >= loadingScrollExtent : false;

  ScrollPosition get scrollPosition => _renderViewport?.offset;

  double get curPixels => scrollPosition != null ? scrollPosition.pixels : 0;

  double get minScrollExtent => scrollPosition?.minScrollExtent;

  double get maxScrollExtent => scrollPosition?.maxScrollExtent;

  double get refreshHeight => _refreshHeight;

  set refreshHeight(double refreshHeight) =>
      _refreshHeight = refreshHeight ?? _refreshHeight;

  double get loadingHeight => _loadingHeight;

  set loadingHeight(double loadingHeight) =>
      _loadingHeight = loadingHeight ?? _loadingHeight;

  /// 是否处在正常滚动范围（不出在isOverTop、isOverBottom状态）
  bool get isScrollNormal => !(scrollPosition?.outOfRange ?? true);

  bool get enableAutoLoading => _enableAutoLoading && _isLoadingAble;

  @override
  RefreshStatus get refreshStatus => _refreshStatus;

  bool get isFooterKeep => _isFooterKeep;

  PullRefreshPhysics get physics {
    ScrollPhysics physics = scrollPosition?.physics;
    if (physics is PullRefreshPhysics) {
      PullRefreshPhysics prlPhysics = physics;
      prlPhysics.attachRefreshData(this);
      return prlPhysics;
    }
    return null;
  }

  void setDefaultComponent(
      {Element scrollElement, RenderViewport renderViewport}) {
    if (scrollElement != null) {
      _scroller = (scrollElement.widget as Scrollable).controller;
    } else if (renderViewport != null) {
      _renderViewport = renderViewport;
    }
  }

  set overFlow(Overflow overFlow) {
    if (overFlow != null) _overflow = overFlow;
  }

  set streamHandle(Stream<Object> streamHandle) {
    if (streamHandle != null) {
      _streamHandle = streamHandle;
      _streamHandle.listen((value) {
        if (value is Notification) handleNotification(value);
      });
    }
  }

///////////////////////////////////分割线///////////////////////////////////////////

  _PullRefreshRender(
      Stream<Object> handle,
      this._refreshHeight,
      this._loadingHeight,
      this._enableAutoLoading,
      OnInitializeCallback onInitialize,
      OnPullChangeCallback onPullChange,
      OnPullHoldTriggerCallback onPullHoldTrigger,
      OnPullHoldUnTriggerCallback onPullHoldUnTrigger,
      OnPullHoldingCallback onPullHolding,
      OnPullFinishCallback onPullFinish,
      OnPullResetCallback onPullReset,
      this._refreshControl,
      this._headerStatus,
      this._footerStatus,
      {List<RenderBox> children,
      Overflow clip}) {
    addAll(children);
    overFlow = clip;
    streamHandle = handle;
    this.onInitialize = onInitialize;
    this.onPullChange = onPullChange;
    this.onPullHoldTrigger = onPullHoldTrigger;
    this.onPullHoldUnTrigger = onPullHoldUnTrigger;
    this.onPullHolding = onPullHolding;
    this.onPullFinish = onPullFinish;
    this.onPullReset = onPullReset;
    _refreshControl?._attachControl(this);
    _onInitialize();
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
    if (childCount == 0) return;
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
        if (_refreshHeight == null) _refreshHeight = child.size.height;
        double offsetY = _headerStatus == IndicatorStatus.follow
            ? -child.size.height - curPixels
            : 0;
        childParentData.offset = Offset(0, offsetY);
      } else if (child is _FooterRender) {
        _footerRender = child;
        if (_loadingHeight == null) _loadingHeight = child.size.height;
        double offsetY = _footerStatus == IndicatorStatus.follow
            ? layoutHeight -
                (curPixels - (maxScrollExtent != null ? maxScrollExtent : 0))
            : layoutHeight - child.size.height;
        childParentData.offset = Offset(0, offsetY);
      }
      child = childParentData.nextSibling;
    }

    size = constraints
        .tighten(
          height: layoutHeight,
        )
        .biggest;
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  void _statusMoveEndNormal() {
    double scrollCenter = maxScrollExtent / 2;
    if (curPixels > scrollCenter &&
            curPixels < maxScrollExtent &&
            _offset > 0 ||
        curPixels < scrollCenter &&
            curPixels > minScrollExtent &&
            _offset < 0) {
      physics?.status = PhysicsStatus.normal;
    }
  }

  void _onInitialize() =>
      _onInitializes.forEach((_, callback) => callback(this));

  void _onPullChange(double offset) =>
      _onPullChanges.forEach((_, callback) => callback(this, offset));

  void _onPullHoldTrigger() =>
      _onPullHoldTriggers.forEach((_, callback) => callback(this));

  void _onPullHoldUnTrigger() =>
      _onPullHoldUnTriggers.forEach((_, callback) => callback(this));

  void _onPullHolding() =>
      _onPullHoldings.forEach((_, callback) => callback(this));

  void _onPullFinish() =>
      _onPullFinishes.forEach((_, callback) => callback(this));

  void _onPullReset() => _onPullResets.forEach((_, callback) => callback(this));
}

class _PullRefreshElement extends MultiChildRenderObjectElement {
  _PullRefreshElement(MultiChildRenderObjectWidget widget) : super(widget);

  @override
  void mount(Element parent, newSlot) {
    super.mount(parent, newSlot);
    findComponentInContent();
  }

  @override
  void update(MultiChildRenderObjectWidget newWidget) {
    super.update(newWidget);
    findComponentInContent();
  }

  findComponentInContent() {
    Element element = children.singleWhere((e) => e is _FindScrollElement);
    findComponent(element);
  }

  void findComponent(Element element) {
    if (element.widget is! _Header &&
        element.widget is! _Footer &&
        element.widget is Scrollable) {
      (renderObject as _PullRefreshRender)
          .setDefaultComponent(scrollElement: element);
      findViewportRender(element);
      return;
    }
    element.visitChildren(findComponent);
    return;
  }

  void findViewportRender(Element element) {
    if (element.renderObject is RenderViewport) {
      (renderObject as _PullRefreshRender)
          .setDefaultComponent(renderViewport: element.renderObject);
      return null;
    }
    element.visitChildren(findViewportRender);
    return null;
  }
}

class _Content extends SingleChildRenderObjectWidget {
  const _Content(Widget child, {Key key}) : super(key: key, child: child);

  @override
  SingleChildRenderObjectElement createElement() {
    return _FindScrollElement(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderProxyBox();
  }
}

class _FindScrollElement extends SingleChildRenderObjectElement {
  _FindScrollElement(Widget widget) : super(widget);
}

class _RefreshParentData extends ContainerBoxParentData<RenderBox> {}

class _Header extends Offstage {
  final bool offstage;

  const _Header(Widget child, {Key key, this.offstage: true})
      : super(key: key, child: child, offstage: offstage);

  @override
  RenderOffstage createRenderObject(BuildContext context) {
    return _HeaderRender(offstage);
  }

  @override
  void updateRenderObject(BuildContext context, RenderOffstage renderObject) {}
}

class _HeaderRender extends RenderOffstage {
  _HeaderRender(offstage) : super(offstage: offstage);
}

class _Footer extends Offstage {
  final bool offstage;

  const _Footer(Widget child, {Key key, this.offstage: false})
      : super(key: key, child: child, offstage: offstage);

  @override
  RenderOffstage createRenderObject(BuildContext context) {
    return _FooterRender(offstage);
  }

  @override
  void updateRenderObject(BuildContext context, RenderOffstage renderObject) {}
}

class _FooterRender extends RenderOffstage {
  _FooterRender(offstage) : super(offstage: offstage);
}

class RefreshControl {
  RefreshControl _control;

  void _attachControl(RefreshControl control) {
    _control = control;
  }

  void finishRefresh({int delay: 300, bool complete}) =>
      _control?.finishRefresh(delay: delay, complete: complete);

  void finishLoading({int delay: 300, bool complete, bool keep}) =>
      _control?.finishLoading(delay: delay, complete: complete, keep: keep);

  void autoRefresh({int delay: 300}) => _control?.autoRefresh(delay: delay);

  bool get isRefreshAble => _control?.isRefreshAble;

  bool get isLoadingAble => _control?.isLoadingAble;

  set isRefreshAble(bool refreshAble) => _control?.isRefreshAble = refreshAble;

  set isLoadingAble(bool loadingAble) => _control?.isLoadingAble = loadingAble;

  bool isRefreshProcess() => _control?.isRefreshProcess();

  bool isLoadingProcess() => _control?.isLoadingProcess();

  RefreshStatus get refreshStatus => _control?.refreshStatus;

  void addOnInitializeCallback(
          String callbackName, OnInitializeCallback onInitializeCall) =>
      _control?.addOnInitializeCallback(callbackName, onInitializeCall);

  void addOnPullChangeCallback(
          String callbackName, OnPullChangeCallback onPullChangeCall) =>
      _control?.addOnPullChangeCallback(callbackName, onPullChangeCall);

  void addOnPullHoldTriggerCallback(String callbackName,
          OnPullHoldTriggerCallback onPullHoldTriggerCall) =>
      _control?.addOnPullHoldTriggerCallback(
          callbackName, onPullHoldTriggerCall);

  void addOnPullHoldUnTriggerCallback(String callbackName,
          OnPullHoldUnTriggerCallback onPullHoldUnTriggerCall) =>
      _control?.addOnPullHoldUnTriggerCallback(
          callbackName, onPullHoldUnTriggerCall);

  void addOnPullHoldingCallback(
          String callbackName, OnPullHoldingCallback onPullHoldingCall) =>
      _control?.addOnPullHoldingCallback(callbackName, onPullHoldingCall);

  void addOnPullFinishCallback(
          String callbackName, OnPullFinishCallback onPullFinishCall) =>
      _control?.addOnPullFinishCallback(callbackName, onPullFinishCall);

  void addOnPullResetCallback(
          String callbackName, OnPullResetCallback onPullResetCall) =>
      _control?.addOnPullResetCallback(callbackName, onPullResetCall);
}
