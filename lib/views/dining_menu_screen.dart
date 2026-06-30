import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';
import '../widgets/scaffold_placeholder.dart';

class DiningMenuScreen extends StatelessWidget {
  const DiningMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlaceholder(
      title: 'Menu tại bàn',
      description: 'View trong MVVM: khách xem món, mở chi tiết món và thêm vào SQLite cart.',
      actions: [
        PrimaryButton(
          label: 'Xem giỏ hàng',
          onPressed: () => context.push('/dining/cart'),
        ),
        OutlinedButton(
          onPressed: () => context.push('/dining/orders'),
          child: const Text('Lịch sử gọi món'),
        ),
      ],
    );
  }
}
