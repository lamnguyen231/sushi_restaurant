import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/sushi_nav_bar.dart';

class WebHomeScreen extends StatelessWidget {
  const WebHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SushiNavBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _HomeHeroImage(),
            _FutureSectionSpace(),
          ],
        ),
      ),
    );
  }
}

class _HomeHeroImage extends StatelessWidget {
  const _HomeHeroImage();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: screenHeight - const SushiNavBar().preferredSize.height,
      child: Image.asset(
        'assets/images/home_screen.jpg',
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}

class _FutureSectionSpace extends StatelessWidget {
  const _FutureSectionSpace();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.eggshell,
      child: SizedBox(height: MediaQuery.sizeOf(context).height * 0.5),
    );
  }
}
