import 'package:flutter/material.dart';

import 'pullrefresharound.dart';

// ignore: must_be_immutable
class PullRefreshPhysics extends ScrollPhysics {
  ScrollPhysics _scrollPhysics;
  ScrollPhysics _parent;
  PhysicsStatus _status;
  bool _scrollAble = true;

  set scrollAble(bool scrollAble) => _scrollAble = scrollAble;

  bool status(PhysicsStatus status) {
    if (status == null) {
      return false;
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
    return isPhysicsSame;
  }

  PullRefreshPhysics({PhysicsStatus status, ScrollPhysics parent})
      : super(parent: parent) {
    _parent = parent;
    this.status(status ?? PhysicsStatus.normal);
  }

  @override
  ScrollPhysics get parent {
    return _parent;
  }

  @override
  PullRefreshPhysics applyTo(ScrollPhysics ancestor) {
    if (_parent == null) {
      _parent = buildParent(ancestor);
    } else {
      _parent = _parent.applyTo(buildParent(ancestor));
    }
    status(_status);
    return this;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) =>
      _scrollPhysics.applyBoundaryConditions(position, value);

  @override
  Simulation createBallisticSimulation(
          ScrollMetrics position, double velocity) =>
      _scrollAble
          ? _scrollPhysics.createBallisticSimulation(position, velocity)
          : null;

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) =>
      _scrollPhysics.shouldAcceptUserOffset(position);

  double carriedMomentum(double existingVelocity) =>
      _scrollPhysics.carriedMomentum(existingVelocity);

  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) =>
      _scrollPhysics.applyPhysicsToUserOffset(position, offset);

  double get minFlingVelocity => _scrollPhysics.minFlingVelocity;

  @override
  bool get allowImplicitScrolling => _scrollPhysics.allowImplicitScrolling;

  double get dragStartDistanceMotionThreshold =>
      _scrollPhysics.dragStartDistanceMotionThreshold;

  @override
  String toString() {
    return super.toString() +
        "  " +
        _scrollAble.toString() +
        "  ScrollPhysics:" +
        _scrollPhysics.toString();
  }
}
