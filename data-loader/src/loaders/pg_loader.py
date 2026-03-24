import psycopg2
import psycopg2.extras
import structlog
from typing import Any

from src.config import settings

logger = structlog.get_logger()


class PostgresLoader:
    """Batch loader for PostgreSQL."""
    
    def __init__(self):
        self.conn = psycopg2.connect(settings.dsn)
        self.conn.autocommit = False
        logger.info("connected_to_postgres", host=settings.postgres_host, db=settings.postgres_db)
    
    def bulk_insert(self, table: str, columns: list[str], rows: list[tuple], schema: str = "raw") -> int:
        """Batch INSERT with COPY for maximum speed."""
        
        full_table = f"{schema}.{table}"
        
        # Use execute_values for good performance
        template = f"({','.join(['%s'] * len(columns))})"
        query = f"INSERT INTO {full_table} ({','.join(columns)}) VALUES %s"
        
        try:
            with self.conn.cursor() as cur:
                psycopg2.extras.execute_values(
                    cur, query, rows,
                    template=template,
                    page_size=settings.batch_size,
                )
            self.conn.commit()
            logger.info("bulk_insert_complete", table=full_table, rows=len(rows))
            return len(rows)
        except Exception as e:
            self.conn.rollback()
            logger.error("bulk_insert_failed", table=full_table, error=str(e))
            raise
    
    def truncate(self, table: str, schema: str = "raw") -> None:
        """Truncate table."""
        with self.conn.cursor() as cur:
            cur.execute(f"TRUNCATE TABLE {schema}.{table} CASCADE")
        self.conn.commit()
        logger.info("table_truncated", table=f"{schema}.{table}")
    
    def execute(self, query: str, params: tuple | None = None) -> list[Any]:
        """Execute arbitrary query."""
        with self.conn.cursor() as cur:
            cur.execute(query, params)
            if cur.description:
                return cur.fetchall()
            self.conn.commit()
            return []
    
    def close(self) -> None:
        self.conn.close()
        logger.info("connection_closed")