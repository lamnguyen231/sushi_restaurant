import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';
import '../widgets/scaffold_placeholder.dart';

class WebHomeScreen extends StatelessWidget {
  const WebHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlaceholder(
      title: 'Website Sushi Restaurant',
      description: 'View trong MVVM: trang công khai cho menu, pickup và đặt bàn trước.',
      actions: [
        PrimaryButton(
          label: 'Xem menu website',
          onPressed: () => context.push('/web/menu'),
        ),
        OutlinedButton(
          onPressed: () => context.push('/web/reservation'),
          child: const Text('Đặt bàn'),
        ),
        OutlinedButton(
          onPressed: () => context.push('/login'),
          child: const Text('Staff login'),
        ),
      ],
    );
  }
}
