import '../models/table_info.dart';

abstract interface class TableRepository {
  Stream<List<TableInfo>> watchTables();

  Future<TableInfo?> getTable(String tableId);
}
