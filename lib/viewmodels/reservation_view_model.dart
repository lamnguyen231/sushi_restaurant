import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/providers/firebase_providers.dart';
import '../models/reservation.dart';
import '../core/enums/app_enums.dart';

part 'reservation_view_model.g.dart';

@riverpod
class ReservationViewModel extends _$ReservationViewModel {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<bool> createReservation({
    required String name,
    required String phone,
    required DateTime dateTime,
    required int guestCount,
    String? note,
  }) async {
    state = const AsyncLoading();
    bool success = false;
    state = await AsyncValue.guard(() async {
      final reservation = Reservation(
        id: '', // Service generates the document ID automatically in Firestore
        customerName: name,
        phone: phone,
        reservationDateTime: dateTime,
        guestCount: guestCount,
        status: ReservationStatus.pending,
        createdAt: DateTime.now(),
        note: note,
      );

      final repo = ref.read(reservationRepositoryProvider);
      await repo.createReservation(reservation);
      success = true;
    });
    return success;
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
