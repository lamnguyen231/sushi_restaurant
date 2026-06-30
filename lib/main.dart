import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  // Firebase.initializeApp() will be added after FlutterFire config generates
  // firebase_options.dart. Keeping main simple lets the scaffold compile now.
  runApp(const ProviderScope(child: SushiRestaurantApp()));
}
