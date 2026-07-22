import '../models/table_info.dart';

abstract interface class TableRepository {
  Stream<List<TableInfo>> watchTables();

  Future<TableInfo?> getTable(String tableId);

  Future<void> addTable({
    required String name,
    required int capacity,
    required String status,
    String? notes,
  });

  Future<void> updateTable({
    required String id,
    required String name,
    required int capacity,
    required String status,
    String? notes,
  });

  Future<void> deleteTable(String id);
}

