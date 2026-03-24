import random
from uuid import uuid4

from faker import Faker

from src.models.product import PriceSegment, Product

fake = Faker()

CATEGORIES = {
    "Electronics": {
        "subcategories": ["Smartphones", "Laptops", "Tablets", "Headphones", "Cameras"],
        "brands": ["Samsung", "Apple", "Sony", "Bose", "Lenovo", "Dell", "Huawei"],
        "price_range": (49.99, 1999.99),
    },
    "Clothing": {
        "subcategories": ["T-Shirts", "Jeans", "Dresses", "Jackets", "Shoes"],
        "brands": ["Nike", "Adidas", "Zara", "H&M", "Puma", "Levi's"],
        "price_range": (9.99, 299.99),
    },
    "Home & Garden": {
        "subcategories": ["Furniture", "Lighting", "Kitchen", "Bedding", "Decor"],
        "brands": ["IKEA", "Bosch", "Philips", "WMF", "Villeroy & Boch"],
        "price_range": (4.99, 899.99),
    },
    "Sports": {
        "subcategories": ["Fitness", "Running", "Cycling", "Outdoor", "Swimming"],
        "brands": ["Nike", "Adidas", "Under Armour", "Puma", "Decathlon"],
        "price_range": (9.99, 499.99),
    },
    "Beauty": {
        "subcategories": ["Skincare", "Makeup", "Haircare", "Fragrance", "Bath & Body"],
        "brands": ["Nivea", "L'Oréal", "Dove", "Rituals", "The Ordinary"],
        "price_range": (3.99, 149.99),
    },
    "Books": {
        "subcategories": ["Fiction", "Non-Fiction", "Tech", "Children", "Comics"],
        "brands": ["Penguin", "HarperCollins", "O'Reilly", "Springer", "Random House"],
        "price_range": (5.99, 59.99),
    },
    "Toys": {
        "subcategories": ["Board Games", "Action Figures", "Puzzles", "LEGO", "Dolls"],
        "brands": ["LEGO", "Hasbro", "Mattel", "Ravensburger", "Playmobil"],
        "price_range": (4.99, 199.99),
    },
}


def _price_segment(price: float) -> PriceSegment:
    if price < 20:
        return PriceSegment.BUDGET
    if price < 50:
        return PriceSegment.STANDARD
    if price < 150:
        return PriceSegment.PREMIUM
    return PriceSegment.LUXURY


def generate_products(count: int) -> list[Product]:
    """Generate a list of products."""

    products = []
    categories = list(CATEGORIES.keys())

    for _ in range(count):
        cat_name = random.choice(categories)
        cat = CATEGORIES[cat_name]

        price = round(random.uniform(*cat["price_range"]), 2)
        margin_pct = random.uniform(0.15, 0.65)
        cost = round(price * (1 - margin_pct), 2)

        product = Product(
            product_id=uuid4(),
            name=f"{random.choice(cat['brands'])} {fake.word().title()} {random.choice(cat['subcategories'])}",
            category=cat_name,
            subcategory=random.choice(cat["subcategories"]),
            brand=random.choice(cat["brands"]),
            price=price,
            cost=cost,
            price_segment=_price_segment(price),
            rating=round(random.uniform(1.0, 5.0), 1),
            reviews_count=random.randint(0, 5000),
            stock_quantity=random.randint(0, 10000),
            is_active=random.random() > 0.05,
        )
        products.append(product)

    return products
