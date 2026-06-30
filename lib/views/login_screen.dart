import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/primary_button.dart';
import '../widgets/scaffold_placeholder.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPlaceholder(
      title: 'Đăng nhập nhân viên',
      description: 'View trong MVVM: hiển thị form login và gọi LoginViewModel.',
      actions: [
        PrimaryButton(
          label: 'Đi tới chọn bàn',
          onPressed: () => context.push('/staff/tables'),
        ),
      ],
    );
  }
}
