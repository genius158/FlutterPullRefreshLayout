typedef OnInitializeCallback = void Function(RefreshControl control);
typedef OnPullChangeCallback = void Function(
    RefreshControl control, double percent);
// 数据重置调用
typedef OnPullHoldTriggerCallback = void Function(RefreshControl control);
typedef OnPullHoldUnTriggerCallback = void Function(RefreshControl control);
typedef OnPullHoldingCallback = void Function(RefreshControl control);
typedef OnPullFinishCallback = void Function(RefreshControl control);
typedef OnPullResetCallback = void Function(RefreshControl control);

enum RefreshStatus { normal, holding, holdTrigger, holdUnTrigger, reset }

abstract class RefreshData {
  double get refreshScrollExtent => null;

  double get loadingScrollExtent => null;

  bool get isToRefreshHolding => false;

  bool get isToLoadingHolding => false;

  bool get enableAutoLoading => false;

  RefreshStatus get refreshStatus => null;
}

enum PhysicsStatus { normal, bouncing }

abstract class RefreshControl {
  void finish({int delay: 300});

  void autoRefresh({int delay: 300});

  bool isRefreshProcess();

  bool isLoadingProcess();

  RefreshStatus get refreshStatus => null;

  void addOnInitializeCallback(
          String callbackName, OnInitializeCallback onInitializeCall) =>
      null;

  void addOnPullChangeCallback(
          String callbackName, OnPullChangeCallback onPullChangeCall) =>
      null;

  void addOnPullHoldTriggerCallback(String callbackName,
          OnPullHoldTriggerCallback onPullHoldTriggerCall) =>
      null;

  void addOnPullHoldUnTriggerCallback(String callbackName,
          OnPullHoldUnTriggerCallback onPullHoldUnTriggerCall) =>
      null;

  void addOnPullHoldingCallback(
          String callbackName, OnPullHoldingCallback onPullHoldingCall) =>
      null;

  void addOnPullFinishCallback(
          String callbackName, OnPullFinishCallback onPullFinishCall) =>
      null;

  void addOnPullResetCallback(
          String callbackName, OnPullResetCallback onPullResetCall) =>
      null;
}
