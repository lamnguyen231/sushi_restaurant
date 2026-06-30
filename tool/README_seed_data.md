# Temporary seed data tool

This folder contains a temporary seed utility for development/demo data.

## Web-only Firestore seeding

If you can only run Flutter Web right now, use:

```bash
flutter run -t tool/seed_firestore_web.dart -d chrome
```

This seeds Firestore only:

- `categories`
- `products`
- `tables`

SQLite/sqflite cannot be created or seeded from Flutter Web. The local SQLite app database is only available on mobile/desktop targets.

## Python SQLite-only seeding

If you only want a local SQLite file with the same tables as `AppDatabase`, run:

```bash
python tool/seed_sqlite.py
```

This creates:

```text
.seeded_sqlite/sushi_restaurant.db
```

It creates all local tables and conditionally seeds only `cached_products`.

Note: this is a development/demo SQLite file. A real mobile/desktop app run creates its own SQLite database in the platform app-data directory.

## Desktop Firestore + SQLite seeding

When a desktop/mobile target is available, run the full seed from the project root:

```bash
flutter run -t tool/seed_data.dart -d windows
```

What it seeds:

- Firestore `categories`
- Firestore `products`
- Firestore `tables`
- SQLite `cached_products`

What it does not seed:

- `local_cart_items`
- `local_dining_session`
- `pending_orders`
- `pending_order_items`

Those tables are created by `AppDatabase`, but they intentionally start empty because real cart/session/order data belongs to active customers.

Seed behavior:

- Each Firestore collection is checked first with `limit(1)`.
- If the collection already has data, that collection is skipped.
- If the collection is empty, fixed document IDs are inserted.
- SQLite `cached_products` is seeded only if it is empty.

You can delete this file and `seed_data.dart` later when the demo data is no longer needed.
