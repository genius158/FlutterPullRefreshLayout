import 'pullrefreshlayout.dart';

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
enum IndicatorStatus { fixed, follow }

abstract class RefreshData {
  double get refreshScrollExtent => null;

  double get loadingScrollExtent => null;

  bool get isToRefreshHolding => false;

  bool get isToLoadingHolding => false;

  bool get enableAutoLoading => false;

  RefreshStatus get refreshStatus => null;
}

enum PhysicsStatus { normal, bouncing }
