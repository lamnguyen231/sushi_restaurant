import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static const _databaseName = 'sushi_restaurant.db';
  static const _databaseVersion = 1;

  static Database? _database;

  static Future<Database> get instance async {
    final existingDatabase = _database;
    if (existingDatabase != null) return existingDatabase;

    final databasePath = p.join(await getDatabasesPath(), _databaseName);
    final openedDatabase = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
    _database = openedDatabase;
    return openedDatabase;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE local_dining_session (
        id TEXT PRIMARY KEY,
        table_id TEXT NOT NULL,
        table_name TEXT,
        status TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        ended_at INTEGER,
        sync_status TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )'''
    );

    await db.execute('''
      CREATE TABLE local_cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        name TEXT NOT NULL,
        unit_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        note TEXT,
        line_total REAL NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(session_id, product_id, note)
      )'''
    );

    await db.execute('''
      CREATE TABLE pending_orders (
        local_id TEXT PRIMARY KEY,
        remote_order_id TEXT,
        idempotency_key TEXT UNIQUE,
        session_id TEXT NOT NULL,
        table_id TEXT NOT NULL,
        status TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        synced_at INTEGER
      )'''
    );

    await db.execute('''
      CREATE TABLE pending_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        name TEXT NOT NULL,
        unit_price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        note TEXT,
        line_total REAL NOT NULL
      )'''
    );

    await db.execute('''
      CREATE TABLE cached_products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category_id TEXT,
        image_url TEXT,
        is_available INTEGER NOT NULL,
        version INTEGER,
        cached_at INTEGER NOT NULL,
        updated_at INTEGER
      )'''
    );
  }
}
