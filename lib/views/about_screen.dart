import 'package:flutter/material.dart';

import '../widgets/scaffold_placeholder.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPlaceholder(
      title: 'About',
      description:
          'Giới thiệu nhà hàng, câu chuyện thương hiệu và phong cách phục vụ sẽ được đặt tại đây.',
    );
  }
}
