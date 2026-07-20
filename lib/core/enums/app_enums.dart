enum UserRole { customer, staff, kitchen, manager }

enum TableStatus { available, reserved, occupied, cleaning, disabled }

enum DiningSessionStatus { active, closed, cancelled }

enum PaymentStatus { unpaid, requested, paid, refunded }

enum DiningPaymentMethod { cash, qr }

enum OrderSource { web, tableDevice }

enum OrderType { dineIn, pickup, delivery }

enum DineInOrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  served,
  completed,
  rejected,
  cancelled,
}

enum ReservationStatus {
  pending,
  confirmed,
  arrived,
  seated,
  completed,
  cancelled,
  noShow,
}

enum SyncStatus { localOnly, syncing, synced, failed }

enum PreparationArea { sushiBar, hotKitchen, drinks }

extension EnumWireName on Enum {
  String get wireName => name;
}
