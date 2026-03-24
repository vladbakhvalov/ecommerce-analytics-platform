import random
from datetime import date, datetime, timedelta, timezone
from uuid import uuid4

from src.models.event import Event, EventType
from src.models.user import User
from src.models.product import Product

# Funnel-like distribution: many page_views, few purchases
EVENT_WEIGHTS = {
    EventType.PAGE_VIEW: 0.35,
    EventType.PRODUCT_VIEW: 0.25,
    EventType.ADD_TO_CART: 0.12,
    EventType.SEARCH: 0.10,
    EventType.LOGIN: 0.06,
    EventType.BEGIN_CHECKOUT: 0.05,
    EventType.REMOVE_FROM_CART: 0.03,
    EventType.PURCHASE: 0.02,
    EventType.SIGNUP: 0.02,
}

DEVICE_WEIGHTS = {"mobile": 0.55, "desktop": 0.35, "tablet": 0.10}

PAGE_URLS = [
    "/", "/products", "/categories", "/sale", "/new-arrivals",
    "/cart", "/checkout", "/account", "/wishlist", "/search",
    "/about", "/contact", "/faq", "/returns", "/blog",
]


def generate_events(
    users: list[User],
    products: list[Product],
    start_date: date,
    end_date: date,
    events_per_day: int,
) -> list[Event]:
    """Generate user behaviour events across the date range."""

    events: list[Event] = []

    event_types = list(EVENT_WEIGHTS.keys())
    event_probs = list(EVENT_WEIGHTS.values())
    devices = list(DEVICE_WEIGHTS.keys())
    device_probs = list(DEVICE_WEIGHTS.values())

    active_users = [u for u in users if u.is_active]
    product_ids = [p.product_id for p in products]

    total_days = (end_date - start_date).days

    for day_offset in range(total_days + 1):
        current_date = start_date + timedelta(days=day_offset)

        # Slight daily variation
        day_count = int(events_per_day * random.uniform(0.7, 1.3))

        for _ in range(day_count):
            user = random.choice(active_users)
            event_type = random.choices(event_types, weights=event_probs, k=1)[0]

            ts = datetime(
                current_date.year, current_date.month, current_date.day,
                random.randint(0, 23), random.randint(0, 59), random.randint(0, 59),
                tzinfo=timezone.utc,
            )

            # Product-related events get a product_id
            product_id = None
            if event_type in (
                EventType.PRODUCT_VIEW,
                EventType.ADD_TO_CART,
                EventType.REMOVE_FROM_CART,
                EventType.PURCHASE,
            ):
                product_id = random.choice(product_ids)

            event = Event(
                event_id=uuid4(),
                user_id=user.user_id,
                event_type=event_type,
                event_timestamp=ts,
                product_id=product_id,
                page_url=random.choice(PAGE_URLS),
                device_type=random.choices(devices, weights=device_probs, k=1)[0],
                session_id=uuid4(),
                country=user.country,
            )
            events.append(event)

    return events
