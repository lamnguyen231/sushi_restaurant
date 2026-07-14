import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/local_cart_item.dart';

/// Service quản lý SQLite cho giỏ hàng tại bàn.
///
/// P3-01: Schema lưu đủ name, unit_price để snapshot giá tại lúc thêm món.
/// P3-02: Cột name và unit_price được lưu cùng với productId.
class SqliteCartService {
  Database? _db;

  // In-memory fallback cho Web để dễ debug
  final List<LocalCartItem> _webMemoryDb = [];

  Future<Database> get db async {
    if (kIsWeb) {
      throw UnsupportedError(
        'Cannot use SQLite on Web without WASM. Using memory fallback.',
      );
    }
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dining_cart.db');

    return await openDatabase(
      path,
      version: 2, // P3-01: bumped from 1 → 2 để thêm cột name, unit_price
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE local_cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id TEXT NOT NULL,
        session_id TEXT NOT NULL,
        name TEXT NOT NULL DEFAULT '',
        unit_price REAL NOT NULL DEFAULT 0,
        quantity INTEGER NOT NULL,
        notes TEXT,
        UNIQUE(product_id, session_id)
      )
    ''');
  }

  /// P3-01: Migration từ v1 (chưa có name/unit_price) → v2.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE local_cart ADD COLUMN name TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        'ALTER TABLE local_cart ADD COLUMN unit_price REAL NOT NULL DEFAULT 0',
      );
    }
  }

  Future<List<LocalCartItem>> getItemsForSession(String sessionId) async {
    if (kIsWeb) {
      return _webMemoryDb.where((e) => e.sessionId == sessionId).toList();
    }
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'local_cart',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
    return maps.map((e) => LocalCartItem.fromMap(e)).toList();
  }

  /// P3-01: upsert tích lũy quantity. name/unit_price từ item mới luôn thắng
  /// (price có thể update nếu nhân viên mở lại phiên và thêm lại).
  Future<void> upsertItem(LocalCartItem item) async {
    if (kIsWeb) {
      final index = _webMemoryDb.indexWhere(
        (e) => e.productId == item.productId && e.sessionId == item.sessionId,
      );
      if (index >= 0) {
        final existing = _webMemoryDb[index];
        _webMemoryDb[index] = existing.copyWith(
          quantity: existing.quantity + item.quantity,
          name: item.name,
          unitPrice: item.unitPrice,
          notes: item.notes,
        );
      } else {
        _webMemoryDb.add(item);
      }
      return;
    }

    final dbClient = await db;
    final maps = await dbClient.query(
      'local_cart',
      where: 'product_id = ? AND session_id = ?',
      whereArgs: [item.productId, item.sessionId],
    );

    if (maps.isEmpty) {
      await dbClient.insert('local_cart', item.toMap());
    } else {
      final existingQty = maps.first['quantity'] as int;
      await dbClient.update(
        'local_cart',
        {
          'quantity': existingQty + item.quantity,
          'name': item.name,
          'unit_price': item.unitPrice,
          'notes': item.notes,
        },
        where: 'product_id = ? AND session_id = ?',
        whereArgs: [item.productId, item.sessionId],
      );
    }
  }

  Future<void> updateItemQuantity(
    String productId,
    String sessionId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeItem(productId, sessionId);
      return;
    }

    if (kIsWeb) {
      final index = _webMemoryDb.indexWhere(
        (e) => e.productId == productId && e.sessionId == sessionId,
      );
      if (index >= 0) {
        _webMemoryDb[index] = _webMemoryDb[index].copyWith(quantity: quantity);
      }
      return;
    }

    final dbClient = await db;
    await dbClient.update(
      'local_cart',
      {'quantity': quantity},
      where: 'product_id = ? AND session_id = ?',
      whereArgs: [productId, sessionId],
    );
  }

  Future<void> removeItem(String productId, String sessionId) async {
    if (kIsWeb) {
      _webMemoryDb.removeWhere(
        (e) => e.productId == productId && e.sessionId == sessionId,
      );
      return;
    }

    final dbClient = await db;
    await dbClient.delete(
      'local_cart',
      where: 'product_id = ? AND session_id = ?',
      whereArgs: [productId, sessionId],
    );
  }

  Future<void> clearSessionCart(String sessionId) async {
    if (kIsWeb) {
      _webMemoryDb.removeWhere((e) => e.sessionId == sessionId);
      return;
    }

    final dbClient = await db;
    await dbClient.delete(
      'local_cart',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }
}
