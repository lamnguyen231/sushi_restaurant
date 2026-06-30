import 'package:flutter/material.dart';

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
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(description, textAlign: TextAlign.center),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Wrap(spacing: 12, runSpacing: 12, children: actions),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
