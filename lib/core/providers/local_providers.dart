import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/dining_session.dart';

import '../../repositories/local_cart_repository.dart';
import '../../services/sqlite_cart_service.dart';

part 'local_providers.g.dart';

@Riverpod(keepAlive: true)
SqliteCartService sqliteCartService(Ref ref) {
  return SqliteCartService();
}

@Riverpod(keepAlive: true)
LocalCartRepository localCartRepository(Ref ref) {
  final service = ref.watch(sqliteCartServiceProvider);
  return LocalCartRepository(service);
}

@Riverpod(keepAlive: true)
class CurrentDiningSession extends _$CurrentDiningSession {
  @override
  DiningSession? build() => null;
  
  void setSession(DiningSession session) => state = session;
  void clear() => state = null;
}