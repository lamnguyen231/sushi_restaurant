import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'ink_frame.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return InkWell(
      onTap: onPressed,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: InkFrame(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          backgroundColor: enabled ? AppTheme.ink : AppTheme.rice,
          borderColor: AppTheme.ink,
          cornerSize: 9,
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: enabled ? AppTheme.paper : AppTheme.mutedInk,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
