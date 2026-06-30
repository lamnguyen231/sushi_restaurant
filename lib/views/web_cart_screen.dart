import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';
import '../widgets/scaffold_placeholder.dart';

class WebCartScreen extends StatelessWidget {
  const WebCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlaceholder(
      title: 'Giỏ hàng website',
      description: 'View trong MVVM: web cart dùng memory/localStorage, không dùng sqflite.',
      actions: [
        PrimaryButton(
          label: 'Pickup checkout',
          onPressed: () => context.push('/web/checkout'),
        ),
      ],
    );
  }
}
