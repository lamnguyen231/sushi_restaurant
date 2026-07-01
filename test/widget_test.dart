import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_restaurant/app.dart';
import 'package:sushi_restaurant/core/providers/firebase_providers.dart';
import 'package:sushi_restaurant/models/app_user.dart';
import 'package:sushi_restaurant/repositories/auth_repository.dart';

void main() {
  testWidgets('Sushi scaffold shows public website home', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(_SignedOutAuth())],
        child: const SushiRestaurantApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('MENU'), findsOneWidget);
    expect(find.text('INFO'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}

class _SignedOutAuth implements AuthRepository {
  @override
  Stream<AppUser?> watchCurrentUser() => Stream.value(null);

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}
}
