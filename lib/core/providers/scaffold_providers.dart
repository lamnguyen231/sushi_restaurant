import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/local/app_database.dart';

part 'scaffold_providers.g.dart';

@riverpod
Future<Database> appDatabase(Ref ref) {
  // This provider is the shared SQLite entry point for cart/session/order cache.
  return AppDatabase.instance;
}
