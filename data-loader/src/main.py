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
        
        loader.bulk_insert("users", User.model_fields.keys(), 
                          [u.model_dump_tuple() for u in users])
        loader.bulk_insert("products", Product.model_fields.keys(),
                          [p.model_dump_tuple() for p in products])
        loader.bulk_insert("campaigns", Campaign.model_fields.keys(),
                          [c.model_dump_tuple() for c in campaigns])
        loader.bulk_insert("orders", Order.model_fields.keys(),
                          [o.model_dump_tuple() for o in orders])
        loader.bulk_insert("order_items", OrderItem.model_fields.keys(),
                          [i.model_dump_tuple() for i in order_items])
        loader.bulk_insert("events", Event.model_fields.keys(),
                          [e.model_dump_tuple() for e in events])
        loader.bulk_insert("campaign_daily_stats", CampaignDailyStats.model_fields.keys(),
                          [s.model_dump_tuple() for s in campaign_stats])
        
        elapsed = time.time() - start
        logger.info("data_generation_complete", elapsed_seconds=round(elapsed, 1))
        
    except Exception as e:
        logger.error("data_generation_failed", error=str(e))
        sys.exit(1)
    finally:
        loader.close()


if __name__ == "__main__":
    main()