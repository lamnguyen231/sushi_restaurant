import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_restaurant/app.dart';

void main() {
  testWidgets('Sushi scaffold shows public website home', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SushiRestaurantApp()),
    );

    expect(find.text('Website Sushi Restaurant'), findsWidgets);
    expect(find.text('Xem menu website'), findsOneWidget);
    expect(find.text('Đặt bàn'), findsOneWidget);

    await tester.tap(find.text('Xem menu website'));
    await tester.pumpAndSettle();

    expect(find.text('Menu website'), findsWidgets);
    expect(find.text('Giỏ hàng web'), findsOneWidget);
  });
}
