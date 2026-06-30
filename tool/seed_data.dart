import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sushi_restaurant/data/local/app_database.dart';
import 'package:sushi_restaurant/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _configureDesktopSqlite();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;
  final sqlite = await AppDatabase.instance;

  await _seedFirestore(firestore);
  await _seedSqlite(sqlite);

  debugPrint('Seed data completed. You can close this runner now.');
  exit(0);
}

void _configureDesktopSqlite() {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

Future<void> _seedFirestore(FirebaseFirestore firestore) async {
  await _seedCollectionIfEmpty(
    firestore: firestore,
    collectionPath: 'categories',
    documents: _categorySeedData,
  );
  await _seedCollectionIfEmpty(
    firestore: firestore,
    collectionPath: 'products',
    documents: _productSeedData,
  );
  await _seedCollectionIfEmpty(
    firestore: firestore,
    collectionPath: 'tables',
    documents: _tableSeedData,
  );
}

Future<void> _seedCollectionIfEmpty({
  required FirebaseFirestore firestore,
  required String collectionPath,
  required Map<String, Map<String, dynamic>> documents,
}) async {
  final existing = await firestore.collection(collectionPath).limit(1).get();
  if (existing.docs.isNotEmpty) {
    debugPrint('$collectionPath already has data. Skipping Firestore seed.');
    return;
  }

  final batch = firestore.batch();
  for (final entry in documents.entries) {
    batch.set(firestore.collection(collectionPath).doc(entry.key), entry.value);
  }
  await batch.commit();
  debugPrint('Seeded Firestore collection: $collectionPath');
}

Future<void> _seedSqlite(Database db) async {
  await _seedCachedProductsIfEmpty(db);
  await _confirmEmptyOperationalTables(db);
}

Future<void> _seedCachedProductsIfEmpty(Database db) async {
  final count =
      Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM cached_products'),
      ) ??
      0;
  if (count > 0) {
    debugPrint('cached_products already has data. Skipping SQLite seed.');
    return;
  }

  final now = DateTime.now().millisecondsSinceEpoch;
  final batch = db.batch();
  for (final entry in _productSeedData.entries) {
    final product = entry.value;
    batch.insert('cached_products', {
      'id': entry.key,
      'name': product['name'],
      'description': product['description'],
      'price': product['price'],
      'category_id': product['categoryId'],
      'image_url': product['imageUrl'],
      'is_available': product['isAvailable'] == true ? 1 : 0,
      'version': 1,
      'cached_at': now,
      'updated_at': now,
    });
  }
  await batch.commit(noResult: true);
  debugPrint('Seeded SQLite table: cached_products');
}

Future<void> _confirmEmptyOperationalTables(Database db) async {
  // These tables should exist after AppDatabase initialization, but they should
  // start empty because real cart/session/order data belongs to active customers.
  final tables = [
    'local_dining_session',
    'local_cart_items',
    'pending_orders',
    'pending_order_items',
  ];

  for (final table in tables) {
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $table'),
        ) ??
        0;
    debugPrint('SQLite table $table ready with $count rows.');
  }
}

final Map<String, Map<String, dynamic>> _categorySeedData = {
  'nigiri': {'name': 'Nigiri', 'displayOrder': 1, 'isActive': true},
  'maki': {'name': 'Maki', 'displayOrder': 2, 'isActive': true},
  'sashimi': {'name': 'Sashimi', 'displayOrder': 3, 'isActive': true},
  'combo': {'name': 'Combo', 'displayOrder': 4, 'isActive': true},
  'drinks': {'name': 'Đồ uống', 'displayOrder': 5, 'isActive': true},
  'side_dish': {'name': 'Món phụ', 'displayOrder': 6, 'isActive': true},
};

final Map<String, Map<String, dynamic>> _productSeedData = {
  'salmon_nigiri': _product(
    name: 'Salmon Nigiri',
    description: 'Cơm nắm sushi với cá hồi tươi.',
    price: 89000,
    categoryId: 'nigiri',
    preparationArea: 'sushi_bar',
  ),
  'tuna_nigiri': _product(
    name: 'Tuna Nigiri',
    description: 'Cơm nắm sushi với cá ngừ tươi.',
    price: 95000,
    categoryId: 'nigiri',
    preparationArea: 'sushi_bar',
  ),
  'california_roll': _product(
    name: 'California Roll',
    description: 'Cuộn sushi với thanh cua, bơ và dưa leo.',
    price: 119000,
    categoryId: 'maki',
    preparationArea: 'sushi_bar',
  ),
  'spicy_tuna_roll': _product(
    name: 'Spicy Tuna Roll',
    description: 'Cuộn cá ngừ cay kiểu Nhật.',
    price: 129000,
    categoryId: 'maki',
    preparationArea: 'sushi_bar',
  ),
  'salmon_sashimi': _product(
    name: 'Salmon Sashimi',
    description: 'Cá hồi sashimi cắt lát tươi.',
    price: 159000,
    categoryId: 'sashimi',
    preparationArea: 'sushi_bar',
  ),
  'sushi_combo_a': _product(
    name: 'Sushi Combo A',
    description: 'Combo sushi tổng hợp cho một người.',
    price: 249000,
    categoryId: 'combo',
    preparationArea: 'sushi_bar',
  ),
  'miso_soup': _product(
    name: 'Miso Soup',
    description: 'Súp miso nóng với rong biển và đậu hũ.',
    price: 39000,
    categoryId: 'side_dish',
    preparationArea: 'hot_kitchen',
  ),
  'green_tea': _product(
    name: 'Green Tea',
    description: 'Trà xanh Nhật Bản.',
    price: 29000,
    categoryId: 'drinks',
    preparationArea: 'drinks',
  ),
};

Map<String, dynamic> _product({
  required String name,
  required String description,
  required double price,
  required String categoryId,
  required String preparationArea,
}) {
  return {
    'name': name,
    'description': description,
    'price': price,
    'categoryId': categoryId,
    'imageUrl': '',
    'isAvailable': true,
    'preparationArea': preparationArea,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

final Map<String, Map<String, dynamic>> _tableSeedData = {
  'table_a1': _table(name: 'Bàn A1', capacity: 4),
  'table_a2': _table(name: 'Bàn A2', capacity: 4),
  'table_a3': _table(name: 'Bàn A3', capacity: 2),
  'table_b1': _table(name: 'Bàn B1', capacity: 6),
  'table_b2': _table(name: 'Bàn B2', capacity: 6),
  'table_vip_1': _table(name: 'Bàn VIP 1', capacity: 8),
};

Map<String, dynamic> _table({required String name, required int capacity}) {
  return {
    'name': name,
    'capacity': capacity,
    'status': 'available',
    'activeSessionId': null,
    'deviceId': null,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
