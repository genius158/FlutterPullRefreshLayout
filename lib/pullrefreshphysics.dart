import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'pullrefresharound.dart';

// ignore: must_be_immutable
class PullRefreshPhysics extends ScrollPhysics {
  ScrollPhysics _scrollPhysics;
  ScrollPhysics _parent;
  PhysicsStatus _status;
  bool _scrollAble = true;
  RefreshData _refreshChannel;

  set scrollAble(bool scrollAble) => _scrollAble = scrollAble;

  void attachRefreshData(RefreshData refreshData) {
    if (refreshData != _refreshChannel) {
      this._refreshChannel = refreshData;
    }
  }

  set status(PhysicsStatus status) {
    if (status == null) {
      return;
    }

    bool isPhysicsSame = _scrollPhysics != null &&
        _scrollPhysics.parent == _parent &&
        _status == status;

    if (status == PhysicsStatus.normal) {
      if (!isPhysicsSame) {
        _scrollPhysics = new AlwaysScrollableScrollPhysics(parent: _parent);
      }
    } else if (status == PhysicsStatus.bouncing) {
      if (!isPhysicsSame) {
        _scrollPhysics = new BouncingScrollPhysics(parent: _parent);
      }
    }
    _status = status;
    return;
  }

  PullRefreshPhysics({PhysicsStatus status, ScrollPhysics parent})
      : super(parent: parent) {
    _parent = parent;
    this.status = status ?? PhysicsStatus.normal;
  }

  @override
  ScrollPhysics get parent => _parent;

  @override
  PullRefreshPhysics applyTo(ScrollPhysics ancestor) {
    if (_parent == null) {
      _parent = buildParent(ancestor);
    } else {
      _parent = _parent.applyTo(buildParent(ancestor));
    }
    status = _status;
    return this;
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if (!_scrollAble) {
      return null;
    }
    if (_refreshChannel == null) {
      return _scrollPhysics.createBallisticSimulation(position, velocity);
    }
    if (_refreshChannel.enableAutoLoading &&
        !_refreshChannel.isToRefreshHolding) {
      position = position.copyWith(
          maxScrollExtent: _refreshChannel.loadingScrollExtent);
    }
    if (_refreshChannel.refreshStatus == RefreshStatus.reset) {
    } else if (_refreshChannel.isToRefreshHolding) {
      position = position.copyWith(
          minScrollExtent: _refreshChannel.refreshScrollExtent);
    } else if (_refreshChannel.isToLoadingHolding) {
      position = position.copyWith(
          maxScrollExtent: _refreshChannel.loadingScrollExtent);
    }
    return _scrollPhysics.createBallisticSimulation(position, velocity);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => true;

  double carriedMomentum(double existingVelocity) {
    return _scrollPhysics.carriedMomentum(existingVelocity);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    return _scrollPhysics.applyBoundaryConditions(position, value);
  }

  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return _scrollPhysics.applyPhysicsToUserOffset(position, offset);
  }

  double get minFlingVelocity => _scrollPhysics.minFlingVelocity;

  @override
  bool get allowImplicitScrolling => _scrollPhysics.allowImplicitScrolling;

  double get dragStartDistanceMotionThreshold =>
      _scrollPhysics.dragStartDistanceMotionThreshold;

  @override
  String toString() {
    return "RefreshPysics " +
        "  scrollable: " +
        _scrollAble.toString() +
        "  curent: " +
        _scrollPhysics.toString() +
        "  parent: " +
        _parent.toString();
  }
}
