# # This part of the project generates realistic dummy data: 50,000 customers, 
# 5,000 products, 20 campaigns, orders, events — and loads them into PostgreSQL. 
# Pydantic models describe the data structure, Faker generates the data, and pg_loader loads it.

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Settings from environment variables (docker-compose → container env)."""
    
    # PostgreSQL
    postgres_host: str
    postgres_port: int
    postgres_db: str
    postgres_user: str
    postgres_password: str
    
    # Data generation
    num_users: int
    num_products: int
    num_campaigns: int
    days_history: int
    events_per_day: int
    
    # Batch size for INSERT
    batch_size: int = 10_000
    
    @property
    def dsn(self) -> str:
        return (
            f"host={self.postgres_host} "
            f"port={self.postgres_port} "
            f"dbname={self.postgres_db} "
            f"user={self.postgres_user} "
            f"password={self.postgres_password}"
        )

    class Config:
        env_prefix = ""
        case_sensitive = False


settings = Settings()