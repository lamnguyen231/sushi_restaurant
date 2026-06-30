import 'package:flutter/material.dart';

import '../widgets/scaffold_placeholder.dart';

class PickupCheckoutScreen extends StatelessWidget {
  const PickupCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPlaceholder(
      title: 'Pickup checkout',
      description: 'View trong MVVM: form đặt món mang về và lưu order source=web orderType=pickup.',
    );
  }
}
