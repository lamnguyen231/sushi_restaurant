import 'package:flutter/material.dart';

enum ScreenClass {
  phone,
  tablet,
  desktop,
}

ScreenClass screenClassOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;

  if (width >= 1200) {
    return ScreenClass.desktop;
  }

  if (width >= 700) {
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
  return isPortraitPhone(context) || isDesktop(context);
}

bool supportsStaffLayout(BuildContext context) {
  return isLandscapeTablet(context) || isDesktop(context);
}