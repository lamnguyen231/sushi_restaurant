import 'package:flutter/material.dart';

import '../widgets/scaffold_placeholder.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPlaceholder(
      title: 'Profile',
      description:
          'Thông tin tài khoản sẽ hiển thị ở đây sau khi hoàn thiện phân quyền người dùng.',
    );
  }
}
