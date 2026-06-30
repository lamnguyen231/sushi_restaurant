import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';
import '../widgets/scaffold_placeholder.dart';

class TableSelectionScreen extends StatelessWidget {
  const TableSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlaceholder(
      title: 'Chọn bàn',
      description: 'View trong MVVM: nhân viên chọn bàn, ViewModel mở session bằng transaction.',
      actions: [
        PrimaryButton(
          label: 'Bắt đầu Customer Mode',
          onPressed: () => context.push('/dining/menu'),
        ),
      ],
    );
  }
}
