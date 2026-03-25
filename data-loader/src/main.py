"""
ShopFlow Data Loader
Generating realistic e-commerce data and importing it into PostgreSQL.
"""
import sys
import time

import structlog

from src.config import settings
from src.models.user import User
from src.models.product import Product
from src.models.campaign import Campaign, CampaignDailyStats
from src.models.order import Order, OrderItem
from src.models.event import Event
from src.generators.user_generator import generate_users
from src.generators.product_generator import generate_products
from src.generators.order_generator import generate_orders
from src.generators.event_generator import generate_events
from src.generators.campaign_generator import generate_campaigns, generate_campaign_stats
from src.loaders.pg_loader import PostgresLoader

logger = structlog.get_logger()


def model_rows(records: list, columns: list[str]) -> list[tuple]:
    """Convert Pydantic models to tuples aligned with target DB columns."""

    rows: list[tuple] = []
    for record in records:
        data = record.model_dump(mode="json")
        rows.append(tuple(data.get(column) for column in columns))
    return rows


def main():
    logger.info(
        "starting_data_generation",
        users=settings.num_users,
        products=settings.num_products,
        campaigns=settings.num_campaigns,
        days=settings.days_history,
    )
    
    start = time.time()
    
    # 1. Connect to PostgreSQL
    loader = PostgresLoader()
    
    try:
        from datetime import date, timedelta
        
        end_date = date.today()
        start_date = end_date - timedelta(days=settings.days_history)
        
        # 2. Generate data
        logger.info("generating_users")
        users = generate_users(settings.num_users, start_date, end_date)
        
        logger.info("generating_products")
        products = generate_products(settings.num_products)
        
        logger.info("generating_campaigns")
        campaigns = generate_campaigns(settings.num_campaigns, start_date, end_date)
        
        logger.info("generating_orders")
        orders, order_items = generate_orders(users, products, campaigns, start_date, end_date)
        
        logger.info("generating_events")
        events = generate_events(users, products, start_date, end_date, settings.events_per_day)
        
        logger.info("generating_campaign_stats")
        campaign_stats = generate_campaign_stats(campaigns, start_date, end_date)
        
        # 3. Load data into PostgreSQL
        logger.info("loading_data_to_postgres")

        for table_name in (
            "campaign_daily_stats",
            "events",
            "order_items",
            "orders",
            "campaigns",
            "products",
            "users",
        ):
            loader.truncate(table_name)
        
        user_columns = [
            "user_id", "email", "first_name", "last_name", "country", "city",
            "registration_date", "birth_date", "gender", "device_type", "segment",
            "clv_tier", "total_orders", "total_revenue", "is_active", "created_at",
        ]
        product_columns = [
            "product_id", "name", "category", "subcategory", "brand", "price", "cost",
            "price_segment", "rating", "reviews_count", "stock_quantity", "is_active", "created_at",
        ]
        campaign_columns = [
            "campaign_id", "name", "channel", "campaign_type", "start_date",
            "end_date", "daily_budget", "is_active",
        ]
        order_columns = [
            "order_id", "user_id", "order_date", "status", "payment_method",
            "shipping_country", "campaign_id",
        ]
        order_item_columns = [
            "order_item_id", "order_id", "product_id", "quantity", "unit_price", "discount_pct",
        ]
        event_columns = [
            "event_id", "user_id", "event_type", "event_timestamp", "product_id",
            "page_url", "device_type", "session_id", "country",
        ]
        campaign_stats_columns = [
            "campaign_id", "stat_date", "impressions", "clicks", "cost", "conversions", "revenue",
        ]

        loader.bulk_insert("users", user_columns, model_rows(users, user_columns))
        loader.bulk_insert("products", product_columns, model_rows(products, product_columns))
        loader.bulk_insert("campaigns", campaign_columns, model_rows(campaigns, campaign_columns))
        loader.bulk_insert("orders", order_columns, model_rows(orders, order_columns))
        loader.bulk_insert("order_items", order_item_columns, model_rows(order_items, order_item_columns))
        loader.bulk_insert("events", event_columns, model_rows(events, event_columns))
        loader.bulk_insert(
            "campaign_daily_stats",
            campaign_stats_columns,
            model_rows(campaign_stats, campaign_stats_columns),
        )
        
        elapsed = time.time() - start
        logger.info("data_generation_complete", elapsed_seconds=round(elapsed, 1))
        
    except Exception as e:
        logger.error("data_generation_failed", error=str(e))
        sys.exit(1)
    finally:
        loader.close()


if __name__ == "__main__":
    main()