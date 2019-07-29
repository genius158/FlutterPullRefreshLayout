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

enum PhysicsStatus { normal, bouncing }

abstract class RefreshControl {
  void finishRefresh();

  void autoRefresh();

  bool isRefresh();

  bool isLoadMore();
}
