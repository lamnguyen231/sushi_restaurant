import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../models/reservation.dart';

part 'reservation_management_view_model.g.dart';

@riverpod
class ReservationManagementViewModel extends _$ReservationManagementViewModel {
  @override
  Stream<List<Reservation>> build() {
    return ref.watch(reservationRepositoryProvider).watchReservations();
  }

  Future<void> updateStatus(String id, ReservationStatus status) async {
    await ref.read(reservationRepositoryProvider).updateReservationStatus(id, status);
  }

  Future<void> assignTable(String id, String? tableId) async {
    await ref.read(reservationRepositoryProvider).assignTable(id, tableId);
  }
}
