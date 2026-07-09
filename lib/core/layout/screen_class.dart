import 'package:flutter/material.dart';

enum ScreenClass { phone, tablet, desktop }

ScreenClass screenClassOf(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final shortestSide = size.shortestSide;

  if (shortestSide >= 900) {
    return ScreenClass.desktop;
  }

  if (shortestSide >= 600) {
    return ScreenClass.tablet;
  }

  return ScreenClass.phone;
}

bool isPortraitPhone(BuildContext context) {
  final screenClass = screenClassOf(context);
  final orientation = MediaQuery.orientationOf(context);

  return screenClass == ScreenClass.phone &&
      orientation == Orientation.portrait;
}

bool isLandscapePhone(BuildContext context) {
  final screenClass = screenClassOf(context);
  final orientation = MediaQuery.orientationOf(context);

  return screenClass == ScreenClass.phone &&
      orientation == Orientation.landscape;
}

bool isLandscapeTablet(BuildContext context) {
  final screenClass = screenClassOf(context);
  final orientation = MediaQuery.orientationOf(context);

  return screenClass == ScreenClass.tablet &&
      orientation == Orientation.landscape;
}

bool isDesktop(BuildContext context) {
  return screenClassOf(context) == ScreenClass.desktop;
}

bool supportsPublicGuestLayout(BuildContext context) {
  return true;
}

bool supportsStaffLayout(BuildContext context) {
  return true;
}
