from pathlib import Path

import duckdb

from src.ingest import ingest, TABLES


def test_ingest_creates_db_file(tmp_path: Path) -> None:
    """Confere se o arquivo do banco é criado após a ingestão."""
    db_path = tmp_path / "test.duckdb"

    ingest(db_path=db_path)

    assert db_path.exists()

def test_ingest_creates_all_tables(tmp_path: Path) -> None:
    """Confere se todas as tabelas esperadas foram criadas."""
    db_path = tmp_path / "test.duckdb"

    ingest(db_path=db_path)

    conn = duckdb.connect(str(db_path))
    existing_tables = {row[0] for row in conn.execute("SHOW TABLES").fetchall()}
    conn.close()

    assert set(TABLES.keys()) == existing_tables

def test_ingest_tables_have_rows(tmp_path: Path) -> None:
    """Confere se nenhuma tabela criada está vazia."""
    db_path = tmp_path / "test.duckdb"

    ingest(db_path=db_path)

    conn = duckdb.connect(str(db_path))
    for table_name in TABLES.keys():
        row_count = conn.execute(f"SELECT COUNT(*) FROM {table_name}").fetchone()[0]
        assert row_count > 0, f"{table_name} está vazia"
    conn.close()
