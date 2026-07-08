import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';
import '../widgets/scaffold_placeholder.dart';

class DiningCartScreen extends StatelessWidget {
  const DiningCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlaceholder(
      title: 'Giỏ hàng tại bàn',
      description: 'View trong MVVM: hiển thị SQLite cart theo session hiện tại.',
      actions: [
        PrimaryButton(
          label: 'Gửi đơn xuống bếp',
          onPressed: () => context.push('/kitchen/orders'),
        ),
      ],
    );
    // idea: change from a cart only to kitchen into a cart/history view
    // and can switch between the two
  }
}
