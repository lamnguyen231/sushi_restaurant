import '../core/enums/app_enums.dart';
import '../models/table_info.dart';
import '../services/firestore_table_service.dart';
import 'table_repository.dart';

class FirestoreTableRepository implements TableRepository {
  const FirestoreTableRepository(this._tableService);

  final FirestoreTableService _tableService;

  @override
  Stream<List<TableInfo>> watchTables() {
    return _tableService.watchTables().map(
      (snapshot) => snapshot.docs.map(_fromDoc).toList(),
    );
  }

  @override
  Future<TableInfo?> getTable(String tableId) async {
    final snapshot = await _tableService.getTable(tableId);
    if (!snapshot.exists) return null;
    return _fromDoc(snapshot);
  }

  TableInfo _fromDoc(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TableInfo(
      id: doc.id as String,
      name: data['name'] as String? ?? doc.id as String,
      capacity: data['capacity'] as int? ?? 0,
      status: _status(data['status'] as String?),
      activeSessionId: data['activeSessionId'] as String?,
      deviceId: data['deviceId'] as String?,
      updatedAt: DateTime.now(),
    );
  }

  TableStatus _status(String? value) {
    return switch (value) {
      'reserved' => TableStatus.reserved,
      'occupied' => TableStatus.occupied,
      'cleaning' => TableStatus.cleaning,
      'disabled' => TableStatus.disabled,
      _ => TableStatus.available,
    };
  }
}
