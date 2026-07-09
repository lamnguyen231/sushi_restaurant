import 'package:flutter/material.dart';

import 'screen_class.dart';

class LayoutGate extends StatelessWidget {
  const LayoutGate({
    required this.isAllowed,
    required this.child,
    required this.title,
    required this.message,
    super.key,
  });

  const LayoutGate.public({required this.child, super.key})
    : isAllowed = supportsPublicGuestLayout,
      title = 'Màn hình chưa được hỗ trợ',
      message = 'Giao diện đang được tối ưu cho kích thước màn hình này.';

  const LayoutGate.staff({required this.child, super.key})
    : isAllowed = supportsStaffLayout,
      title = 'Chế độ nhân viên cần màn hình ngang',
      message =
          'Giao diện nhân viên đang được tối ưu cho kích thước màn hình này.';

  final bool Function(BuildContext context) isAllowed;
  final Widget child;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class UnsupportedLayoutView extends StatelessWidget {
  const UnsupportedLayoutView({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.screen_rotation_alt_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
