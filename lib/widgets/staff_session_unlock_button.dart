import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/app_user.dart';
import '../models/dining_session.dart';

class StaffSessionUnlockButton extends ConsumerWidget {
  const StaffSessionUnlockButton({
    super.key,
    required this.session,
    this.iconOnly = false,
  });

  final DiningSession session;
  final bool iconOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final onPressed = userState.hasValue
        ? () => _unlockReceipt(context, userState.value)
        : null;

    if (iconOnly) {
      return IconButton(
        tooltip: userState.isLoading ? 'Đang xác thực nhân viên' : 'Nhân viên',
        color: AppTheme.paper,
        onPressed: onPressed,
        icon: userState.isLoading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.lock_open),
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.lock_open),
      label: Text(userState.isLoading ? 'Đang xác thực' : 'Nhân viên'),
      style: TextButton.styleFrom(foregroundColor: AppTheme.paper),
    );
  }

  Future<void> _unlockReceipt(BuildContext context, AppUser? user) async {
    final canUnlock =
        user?.role == UserRole.manager || user?.id == session.openedBy;
    if (!canUnlock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ nhân viên mở phiên hoặc quản lý được mở khóa.'),
        ),
      );
      return;
    }

    final unlocked = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _StaffPinDialog(),
    );
    if (!context.mounted || unlocked != true) return;
    context.go('/dining/receipt', extra: session.id);
  }
}

class _StaffPinDialog extends StatefulWidget {
  const _StaffPinDialog();

  @override
  State<_StaffPinDialog> createState() => _StaffPinDialogState();
}

class _StaffPinDialogState extends State<_StaffPinDialog> {
  final _controller = TextEditingController();
  int _attempts = 0;
  bool _locked = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mở khóa nhân viên'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nhập PIN nhân viên để mở hóa đơn và thanh toán.'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            enabled: !_locked,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'PIN',
              helperText: 'PIN demo: 1234',
              errorText: _errorText,
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_locked) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset số lần thử'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _locked ? null : _submit,
          child: const Text('Mở khóa'),
        ),
      ],
    );
  }

  void _submit() {
    if (_locked) return;
    if (_controller.text.trim() == '1234') {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _attempts++;
      _controller.clear();
      if (_attempts >= 3) {
        _locked = true;
        _errorText = 'Sai PIN 3 lần. Bấm reset để thử lại khi demo.';
      } else {
        _errorText = 'Sai PIN. Còn ${3 - _attempts} lần thử.';
      }
    });
  }

  void _reset() {
    setState(() {
      _attempts = 0;
      _locked = false;
      _errorText = null;
      _controller.clear();
    });
  }
}
