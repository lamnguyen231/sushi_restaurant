import 'package:flutter/material.dart';

import '../widgets/scaffold_placeholder.dart';

class ReservationScreen extends StatelessWidget {
  const ReservationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPlaceholder(
      title: 'Đặt bàn trước',
      description: 'View trong MVVM: form reservation lưu vào Firestore collection reservations.',
    );
  }
}
