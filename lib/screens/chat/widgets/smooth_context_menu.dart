import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Плавный контекстный меню с уменьшенными анимациями
class SmoothContextMenu extends StatelessWidget {
  final List<CupertinoContextMenuAction> actions;
  final Widget child;

  const SmoothContextMenu({
    super.key,
    required this.actions,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoContextMenu(
      actions: actions,
      child: child,
    );
  }
}
