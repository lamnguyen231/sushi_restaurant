import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_restaurant/app.dart';
import 'package:sushi_restaurant/core/layout/layout_gate.dart';
import 'package:sushi_restaurant/core/providers/firebase_providers.dart';
import 'package:sushi_restaurant/models/app_user.dart';
import 'package:sushi_restaurant/repositories/auth_repository.dart';

void main() {
  testWidgets('Sushi scaffold shows public website home', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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

  testWidgets('Public home supports phone portrait without app bar overflow', (
    tester,
  ) async {
    await _pumpAtSize(tester, const Size(360, 780));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
    expect(find.text('Màn hình chưa được hỗ trợ'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Public home supports phone landscape', (tester) async {
    await _pumpAtSize(tester, const Size(780, 360));

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Màn hình chưa được hỗ trợ'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Public home supports compact tablet portrait range', (
    tester,
  ) async {
    await _pumpAtSize(tester, const Size(895, 1024));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.text('Màn hình chưa được hỗ trợ'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Public home supports compact tablet landscape range', (
    tester,
  ) async {
    await _pumpAtSize(tester, const Size(624, 762));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.text('Màn hình chưa được hỗ trợ'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Public home supports wide tablet landscape range', (
    tester,
  ) async {
    await _pumpAtSize(tester, const Size(1453, 762));

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('Màn hình chưa được hỗ trợ'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Staff gate does not block phone portrait', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 780);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: LayoutGate.staff(child: Text('Staff content'))),
    );

    expect(find.text('Staff content'), findsOneWidget);
    expect(find.text('Chế độ nhân viên cần màn hình ngang'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpAtSize(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(_SignedOutAuth())],
      child: const SushiRestaurantApp(),
    ),
  );
  await tester.pumpAndSettle();
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

  @override
  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? cccd,
  }) async {}
}
