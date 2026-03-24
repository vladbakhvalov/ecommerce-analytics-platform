import random
from datetime import date, datetime, timedelta, timezone
from uuid import uuid4

from src.models.order import Order, OrderItem, OrderStatus
from src.models.user import User
from src.models.product import Product
from src.models.campaign import Campaign

PAYMENT_METHODS = ["credit_card", "paypal", "bank_transfer", "klarna"]
PAYMENT_WEIGHTS = [0.40, 0.25, 0.15, 0.20]

STATUS_WEIGHTS = {
    OrderStatus.DELIVERED: 0.55,
    OrderStatus.SHIPPED: 0.15,
    OrderStatus.CONFIRMED: 0.10,
    OrderStatus.PENDING: 0.05,
    OrderStatus.CANCELLED: 0.10,
    OrderStatus.REFUNDED: 0.05,
}


def generate_orders(
    users: list[User],
    products: list[Product],
    campaigns: list[Campaign],
    start_date: date,
    end_date: date,
) -> tuple[list[Order], list[OrderItem]]:
    """Generate orders and order items based on users, products, and campaigns."""

    orders: list[Order] = []
    all_items: list[OrderItem] = []

    active_products = [p for p in products if p.is_active]
    statuses = list(STATUS_WEIGHTS.keys())
    status_probs = list(STATUS_WEIGHTS.values())
    date_range = (end_date - start_date).days

    campaign_ids = [c.campaign_id for c in campaigns]

    for user in users:
        # Each user places 0-15 orders, weighted toward lower counts
        num_orders = max(0, int(random.gauss(3, 3)))
        num_orders = min(num_orders, 15)

        earliest = max(start_date, user.registration_date)
        if earliest > end_date:
            continue

        user_date_range = (end_date - earliest).days
        if user_date_range <= 0:
            continue

        for _ in range(num_orders):
            order_date_offset = random.randint(0, user_date_range)
            order_dt = datetime(
                earliest.year, earliest.month, earliest.day,
                random.randint(0, 23), random.randint(0, 59), random.randint(0, 59),
                tzinfo=timezone.utc,
            ) + timedelta(days=order_date_offset)

            order_id = uuid4()

            # 30% of orders attributed to a campaign
            campaign_id = random.choice(campaign_ids) if random.random() < 0.30 else None

            # 1-5 items per order
            num_items = random.randint(1, 5)
            chosen_products = random.sample(active_products, min(num_items, len(active_products)))

            items: list[OrderItem] = []
            for prod in chosen_products:
                discount = random.choice([0.0, 0.0, 0.0, 0.05, 0.10, 0.15, 0.20])
                item = OrderItem(
                    order_item_id=uuid4(),
                    order_id=order_id,
                    product_id=prod.product_id,
                    quantity=random.randint(1, 3),
                    unit_price=prod.price,
                    discount_pct=discount,
                )
                items.append(item)

            order = Order(
                order_id=order_id,
                user_id=user.user_id,
                order_date=order_dt,
                status=random.choices(statuses, weights=status_probs, k=1)[0],
                payment_method=random.choices(PAYMENT_METHODS, weights=PAYMENT_WEIGHTS, k=1)[0],
                shipping_country=user.country,
                campaign_id=campaign_id,
                items=items,
            )

            orders.append(order)
            all_items.extend(items)

    return orders, all_items
