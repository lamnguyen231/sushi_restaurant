from __future__ import annotations

import sqlite3
from pathlib import Path
from time import time


ROOT = Path(__file__).resolve().parents[1]
DATABASE_DIR = ROOT / ".seeded_sqlite"
DATABASE_PATH = DATABASE_DIR / "sushi_restaurant.db"


PRODUCTS = {
    "salmon_nigiri": {
        "name": "Salmon Nigiri",
        "description": "Cơm nắm sushi với cá hồi tươi.",
        "price": 89000,
        "category_id": "nigiri",
        "image_url": "",
        "is_available": 1,
    },
    "tuna_nigiri": {
        "name": "Tuna Nigiri",
        "description": "Cơm nắm sushi với cá ngừ tươi.",
        "price": 95000,
        "category_id": "nigiri",
        "image_url": "",
        "is_available": 1,
    },
    "california_roll": {
        "name": "California Roll",
        "description": "Cuộn sushi với thanh cua, bơ và dưa leo.",
        "price": 119000,
        "category_id": "maki",
        "image_url": "",
        "is_available": 1,
    },
    "spicy_tuna_roll": {
        "name": "Spicy Tuna Roll",
        "description": "Cuộn cá ngừ cay kiểu Nhật.",
        "price": 129000,
        "category_id": "maki",
        "image_url": "",
        "is_available": 1,
    },
    "salmon_sashimi": {
        "name": "Salmon Sashimi",
        "description": "Cá hồi sashimi cắt lát tươi.",
        "price": 159000,
        "category_id": "sashimi",
        "image_url": "",
        "is_available": 1,
    },
    "sushi_combo_a": {
        "name": "Sushi Combo A",
        "description": "Combo sushi tổng hợp cho một người.",
        "price": 249000,
        "category_id": "combo",
        "image_url": "",
        "is_available": 1,
    },
    "miso_soup": {
        "name": "Miso Soup",
        "description": "Súp miso nóng với rong biển và đậu hũ.",
        "price": 39000,
        "category_id": "side_dish",
        "image_url": "",
        "is_available": 1,
    },
    "green_tea": {
        "name": "Green Tea",
        "description": "Trà xanh Nhật Bản.",
        "price": 29000,
        "category_id": "drinks",
        "image_url": "",
        "is_available": 1,
    },
}


def main() -> None:
    DATABASE_DIR.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(DATABASE_PATH) as connection:
        create_tables(connection)
        seed_cached_products_if_empty(connection)
        print_table_counts(connection)

    print(f"SQLite seed completed: {DATABASE_PATH}")


def create_tables(connection: sqlite3.Connection) -> None:
    connection.executescript(
        """
        CREATE TABLE IF NOT EXISTS local_dining_session (
          id TEXT PRIMARY KEY,
          table_id TEXT NOT NULL,
          table_name TEXT,
          status TEXT NOT NULL,
          started_at INTEGER NOT NULL,
          ended_at INTEGER,
          sync_status TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        );

        CREATE TABLE IF NOT EXISTS local_cart_items (
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
        );

        CREATE TABLE IF NOT EXISTS pending_orders (
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
        );

        CREATE TABLE IF NOT EXISTS pending_order_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id TEXT NOT NULL,
          product_id TEXT NOT NULL,
          name TEXT NOT NULL,
          unit_price REAL NOT NULL,
          quantity INTEGER NOT NULL,
          note TEXT,
          line_total REAL NOT NULL
        );

        CREATE TABLE IF NOT EXISTS cached_products (
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
        );
        """
    )


def seed_cached_products_if_empty(connection: sqlite3.Connection) -> None:
    count = connection.execute("SELECT COUNT(*) FROM cached_products").fetchone()[0]
    if count:
        print("cached_products already has data. Skipping SQLite product seed.")
        return

    now = int(time() * 1000)
    rows = [
        (
            product_id,
            product["name"],
            product["description"],
            product["price"],
            product["category_id"],
            product["image_url"],
            product["is_available"],
            1,
            now,
            now,
        )
        for product_id, product in PRODUCTS.items()
    ]

    connection.executemany(
        """
        INSERT INTO cached_products (
          id,
          name,
          description,
          price,
          category_id,
          image_url,
          is_available,
          version,
          cached_at,
          updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        rows,
    )
    print(f"Seeded cached_products with {len(rows)} rows.")


def print_table_counts(connection: sqlite3.Connection) -> None:
    tables = [
        "local_dining_session",
        "local_cart_items",
        "pending_orders",
        "pending_order_items",
        "cached_products",
    ]
    for table in tables:
        count = connection.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        print(f"{table}: {count} rows")


if __name__ == "__main__":
    main()
