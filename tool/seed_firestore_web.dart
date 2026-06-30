import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sushi_restaurant/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const SeedFirestoreWebApp());
}

class SeedFirestoreWebApp extends StatefulWidget {
  const SeedFirestoreWebApp({super.key});

  @override
  State<SeedFirestoreWebApp> createState() => _SeedFirestoreWebAppState();
}

class _SeedFirestoreWebAppState extends State<SeedFirestoreWebApp> {
  final List<String> _logs = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _runSeed();
  }

  Future<void> _runSeed() async {
    setState(() {
      _isRunning = true;
      _logs.clear();
    });

    try {
      final firestore = FirebaseFirestore.instance;
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
      _addLog('Firestore seed completed. You can close this browser tab.');
    } catch (error) {
      _addLog('Seed failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isRunning = false);
      }
    }
  }

  Future<void> _seedCollectionIfEmpty({
    required FirebaseFirestore firestore,
    required String collectionPath,
    required Map<String, Map<String, dynamic>> documents,
  }) async {
    final existing = await firestore.collection(collectionPath).limit(1).get();
    if (existing.docs.isNotEmpty) {
      _addLog('$collectionPath already has data. Skipping.');
      return;
    }

    final batch = firestore.batch();
    for (final entry in documents.entries) {
      batch.set(
        firestore.collection(collectionPath).doc(entry.key),
        entry.value,
      );
    }
    await batch.commit();
    _addLog('Seeded $collectionPath (${documents.length} documents).');
  }

  void _addLog(String message) {
    setState(() => _logs.add(message));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Seed Firestore Web')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Temporary Firestore Seeder',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'This seeds Firestore only. SQLite/sqflite cannot run on Flutter Web.',
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isRunning ? null : _runSeed,
                child: Text(_isRunning ? 'Seeding...' : 'Run seed again'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) => Text('• ${_logs[index]}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
