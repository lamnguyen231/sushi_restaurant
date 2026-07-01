import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'ink_frame.dart';
import 'sushi_nav_bar.dart';

class ScaffoldPlaceholder extends StatelessWidget {
  const ScaffoldPlaceholder({
    required this.title,
    required this.description,
    super.key,
    this.actions = const [],
  });

  final String title;
  final String description;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SushiNavBar(),
      body: Stack(
        children: [
          const _SubtlePaperWash(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: InkFrame(
                  padding: const EdgeInsets.fromLTRB(36, 42, 36, 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Container(width: 96, height: 1, color: AppTheme.ink),
                      const SizedBox(height: 18),
                      Text(description, textAlign: TextAlign.center),
                      if (actions.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: actions,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubtlePaperWash extends StatelessWidget {
  const _SubtlePaperWash();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.eggshell,
              AppTheme.paper,
              AppTheme.rice.withValues(alpha: 0.64),
            ],
          ),
        ),
      ),
    );
  }
}
