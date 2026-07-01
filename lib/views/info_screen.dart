import 'package:flutter/material.dart';

import '../widgets/scaffold_placeholder.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPlaceholder(
      title: 'Info',
      description:
          'Thông tin giờ mở cửa, địa chỉ, liên hệ và chính sách đặt bàn sẽ được đặt tại đây.',
    );
  }
}
