import duckdb
from pathlib import Path

RAW_DATA_DIR = Path("data/raw")
DB_PATH = Path("data/processed/olist.duckdb")

TABLES = {
    "customers": "olist_customers_dataset.csv",
    "geolocation": "olist_geolocation_dataset.csv",
    "orders": "olist_orders_dataset.csv",
    "order_items": "olist_order_items_dataset.csv",
    "payments": "olist_order_payments_dataset.csv",
    "reviews": "olist_order_reviews_dataset.csv",
    "products": "olist_products_dataset.csv",
    "sellers": "olist_sellers_dataset.csv",
    "product_category_name_translation": "product_category_name_translation.csv",
}


def ingest(raw_data_dir: Path = RAW_DATA_DIR, db_path: Path = DB_PATH) -> None:
    db_path.parent.mkdir(parents=True, exist_ok=True)
    conn = duckdb.connect(str(db_path))

    for table_name, csv_filename in TABLES.items():
        csv_path = raw_data_dir / csv_filename
        conn.execute(
            f"CREATE OR REPLACE TABLE {table_name} AS "
            f"SELECT * FROM read_csv_auto('{csv_path.as_posix()}')"
        )
        row_count = conn.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        print(f"{table_name}: {row_count} linhas")

    conn.close()


if __name__ == "__main__":
    ingest()
