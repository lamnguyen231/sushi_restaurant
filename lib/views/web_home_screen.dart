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
    final heroHeight = screenHeight - const SushiNavBar().preferredSize.height;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home_screen.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          Container(
            color: Colors.black.withValues(alpha: 0.25),
          ),

          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, 0.4),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'ス\nィ\nシ\nュ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          letterSpacing: 6,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Sishu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
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
