import 'package:flutter/material.dart';

import '../widgets/scaffold_placeholder.dart';

class KitchenOrdersScreen extends StatelessWidget {
  const KitchenOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPlaceholder(
      title: 'Bếp - đơn mới',
      description: 'View trong MVVM: bếp lắng nghe Firestore realtime; FCM chỉ là cảnh báo.',
    );
  }
}
