import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class InkFrame extends StatelessWidget {
  const InkFrame({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = AppTheme.paper,
    this.borderColor = AppTheme.ink,
    this.cornerSize = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double cornerSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
      ),
      child: Stack(
        children: [
          Padding(padding: padding, child: child),
          _CornerMark(alignment: Alignment.topLeft, size: cornerSize),
          _CornerMark(alignment: Alignment.topRight, size: cornerSize),
          _CornerMark(alignment: Alignment.bottomLeft, size: cornerSize),
          _CornerMark(alignment: Alignment.bottomRight, size: cornerSize),
        ],
      ),
    );
  }
}

class _CornerMark extends StatelessWidget {
  const _CornerMark({required this.alignment, required this.size});

  final Alignment alignment;
  final double size;

  @override
  Widget build(BuildContext context) {
    final top = alignment.y < 0 ? 4.0 : null;
    final bottom = alignment.y > 0 ? 4.0 : null;
    final left = alignment.x < 0 ? 4.0 : null;
    final right = alignment.x > 0 ? 4.0 : null;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: alignment.y < 0
                  ? const BorderSide(color: AppTheme.ink, width: 2)
                  : BorderSide.none,
              bottom: alignment.y > 0
                  ? const BorderSide(color: AppTheme.ink, width: 2)
                  : BorderSide.none,
              left: alignment.x < 0
                  ? const BorderSide(color: AppTheme.ink, width: 2)
                  : BorderSide.none,
              right: alignment.x > 0
                  ? const BorderSide(color: AppTheme.ink, width: 2)
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
