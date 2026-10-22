import 'package:flutter/material.dart';

/// App-wide [ScaffoldMessenger] that keeps snack bars short and stops the
/// same message from stacking up when an action is triggered repeatedly.
///
/// - Snack bars without an action are shown for at most [maxDuration].
/// - A snack bar whose text matches the one still showing is ignored instead
///   of being queued behind it.
class AppScaffoldMessenger extends ScaffoldMessenger {
  const AppScaffoldMessenger({super.key, required super.child});

  static const Duration maxDuration = Duration(seconds: 3);

  @override
  ScaffoldMessengerState createState() => _AppScaffoldMessengerState();
}

class _AppScaffoldMessengerState extends ScaffoldMessengerState {
  String? _lastText;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _lastController;

  @override
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    SnackBar snackBar, {
    AnimationStyle? snackBarAnimationStyle,
  }) {
    final text = _plainText(snackBar.content);
    // Same message still on screen (e.g. a button tapped repeatedly): keep
    // the one that's showing instead of queueing another copy.
    if (text != null && text == _lastText && _lastController != null) {
      return _lastController!;
    }

    final controller = super.showSnackBar(
      _capDuration(snackBar),
      snackBarAnimationStyle: snackBarAnimationStyle,
    );
    _lastText = text;
    _lastController = controller;
    controller.closed.then((_) {
      if (identical(_lastController, controller)) {
        _lastText = null;
        _lastController = null;
      }
    });
    return controller;
  }

  // Callers often hide the current snack bar and then show a new one; a
  // message that is being hidden must not swallow the next identical one.
  @override
  void hideCurrentSnackBar({
    SnackBarClosedReason reason = SnackBarClosedReason.hide,
  }) {
    _lastText = null;
    _lastController = null;
    super.hideCurrentSnackBar(reason: reason);
  }

  @override
  void removeCurrentSnackBar({
    SnackBarClosedReason reason = SnackBarClosedReason.remove,
  }) {
    _lastText = null;
    _lastController = null;
    super.removeCurrentSnackBar(reason: reason);
  }

  SnackBar _capDuration(SnackBar s) {
    if (s.action != null || s.duration <= AppScaffoldMessenger.maxDuration) {
      return s;
    }
    return SnackBar(
      key: s.key,
      content: s.content,
      backgroundColor: s.backgroundColor,
      elevation: s.elevation,
      margin: s.margin,
      padding: s.padding,
      width: s.width,
      shape: s.shape,
      hitTestBehavior: s.hitTestBehavior,
      behavior: s.behavior,
      actionOverflowThreshold: s.actionOverflowThreshold,
      showCloseIcon: s.showCloseIcon,
      closeIconColor: s.closeIconColor,
      duration: AppScaffoldMessenger.maxDuration,
      persist: s.persist,
      animation: s.animation,
      onVisible: s.onVisible,
      dismissDirection: s.dismissDirection,
      clipBehavior: s.clipBehavior,
    );
  }

  static String? _plainText(Widget content) {
    if (content is Text) {
      return content.data ?? content.textSpan?.toPlainText();
    }
    return null;
  }
}
