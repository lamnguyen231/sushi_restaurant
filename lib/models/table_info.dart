import '../core/enums/app_enums.dart';

class TableInfo {
  const TableInfo({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
    required this.updatedAt,
    this.activeSessionId,
    this.deviceId,
  });

  final String id;
  final String name;
  final int capacity;
  final TableStatus status;
  final String? activeSessionId;
  final String? deviceId;
  final DateTime updatedAt;
}
