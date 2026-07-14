import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../core/providers/local_providers.dart';
import '../models/order_item.dart';

part 'pending_order_sync_service.g.dart';

class PendingOrderSyncService {
  PendingOrderSyncService(this.ref);

  final Ref ref;
  Timer? _syncTimer;

  void startPeriodicSync() {
    _syncTimer?.cancel();
    // Run sync every 20 seconds
    _syncTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      syncPendingOrders();
    });
  }

  void stopSync() {
    _syncTimer?.cancel();
  }

  Future<bool> hasInternet() async {
    if (kIsWeb) {
      // On web we check using a simple fetch/ping or assume online
      return true; 
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> syncPendingOrders() async {
    final localRepo = ref.read(localPendingOrderRepositoryProvider);
    final orders = await localRepo.getOrders();
    final pendingOrders = orders.where((o) => o.status == SyncStatus.localOnly || o.status == SyncStatus.failed).toList();

    if (pendingOrders.isEmpty) return;

    final online = await hasInternet();
    if (!online) return;

    final firestoreService = ref.read(firestoreOrderServiceProvider);

    for (final order in pendingOrders) {
      try {
        // Set state to syncing
        await localRepo.updateStatus(
          localId: order.localId,
          status: SyncStatus.syncing.name,
        );

        final orderItems = order.items.map((item) => OrderItem(
          productId: item.productId,
          productName: item.name,
          unitPrice: item.unitPrice,
          quantity: item.quantity,
          note: item.note,
          lineTotal: item.lineTotal,
        )).toList();

        final subtotal = orderItems.fold<double>(0, (total, item) => total + item.lineTotal);

        // Upload to Firestore
        final docRef = await firestoreService.createOrder({
          'source': OrderSource.tableDevice.name,
          'orderType': OrderType.dineIn.name,
          'sessionId': order.sessionId,
          'tableId': order.tableId,
          'items': orderItems.map((item) => {
            'productId': item.productId,
            'productName': item.productName,
            'unitPrice': item.unitPrice,
            'quantity': item.quantity,
            'note': item.note,
            'lineTotal': item.lineTotal,
          }).toList(),
          'subtotal': subtotal,
          'deliveryFee': 0,
          'discount': 0,
          'grandTotal': subtotal,
          'status': DineInOrderStatus.pending.name,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'idempotencyKey': order.idempotencyKey,
        });

        // Update local status to synced
        await localRepo.updateStatus(
          localId: order.localId,
          status: SyncStatus.synced.name,
          remoteOrderId: docRef.id,
          syncedAt: DateTime.now().millisecondsSinceEpoch,
        );
      } catch (e) {
        // Update local status to failed
        await localRepo.updateStatus(
          localId: order.localId,
          status: SyncStatus.failed.name,
          lastError: e.toString(),
          retryCount: order.retryCount + 1,
        );
      }
    }
  }
}

@Riverpod(keepAlive: true)
PendingOrderSyncService pendingOrderSync(Ref ref) {
  final service = PendingOrderSyncService(ref);
  service.startPeriodicSync();
  ref.onDispose(() {
    service.stopSync();
  });
  return service;
}
