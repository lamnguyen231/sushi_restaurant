import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';
import '../widgets/scaffold_placeholder.dart';

class WebMenuScreen extends StatelessWidget {
  const WebMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlaceholder(
      title: 'Menu website',
      description: 'View trong MVVM: website dùng chung ProductRepository nhưng không dùng sqflite.',
      actions: [
        PrimaryButton(
          label: 'Giỏ hàng web',
          onPressed: () => context.push('/web/cart'),
        ),
      ],
    );
  }
}
