import 'package:flutter_test/flutter_test.dart';
import 'package:sushi_restaurant/models/dine_in_order_payload.dart';

void main() {
  test('recomputes line totals, subtotal, and item count', () {
    final payload = DineInOrderPayload.fromItems([
      {
        'productId': 'salmon',
        'productName': 'Salmon Nigiri',
        'unitPrice': 45000,
        'quantity': 2,
        'note': null,
        'lineTotal': 1,
      },
      {
        'productId': 'tea',
        'productName': 'Green Tea',
        'unitPrice': 15000.0,
        'quantity': 1,
        'lineTotal': 999999,
      },
    ]);

    expect(payload.items[0]['lineTotal'], 90000);
    expect(payload.items[1]['lineTotal'], 15000);
    expect(payload.subtotal, 105000);
    expect(payload.itemCount, 3);
  });

  test('rejects non-positive quantities', () {
    expect(
      () => DineInOrderPayload.fromItems([
        {
          'productId': 'salmon',
          'productName': 'Salmon Nigiri',
          'unitPrice': 45000,
          'quantity': -1,
        },
      ]),
      throwsStateError,
    );
  });

  test('rejects invalid prices and empty orders', () {
    expect(() => DineInOrderPayload.fromItems(const []), throwsStateError);
    expect(
      () => DineInOrderPayload.fromItems([
        {
          'productId': 'salmon',
          'productName': 'Salmon Nigiri',
          'unitPrice': double.nan,
          'quantity': 1,
        },
      ]),
      throwsStateError,
    );
  });
}
