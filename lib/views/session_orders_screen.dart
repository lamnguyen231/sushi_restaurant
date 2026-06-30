import 'package:flutter/material.dart';

import '../widgets/scaffold_placeholder.dart';

class SessionOrdersScreen extends StatelessWidget {
  const SessionOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPlaceholder(
      title: 'Đơn trong phiên',
      description: 'View trong MVVM: hiển thị các lần gọi món thuộc dining session hiện tại.',
    );
  }
}
