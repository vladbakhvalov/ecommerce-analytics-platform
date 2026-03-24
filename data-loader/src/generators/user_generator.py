import random
from datetime import date, timedelta
from uuid import uuid4

from faker import Faker

from src.models.user import CLVTier, User, UserSegment

# German and international locale
fake_de = Faker("de_DE")
fake_en = Faker("en_US")

# Distribution by country (DACH + EU)
COUNTRY_WEIGHTS = {
    "DE": 0.45,
    "AT": 0.10,
    "CH": 0.08,
    "NL": 0.07,
    "FR": 0.06,
    "PL": 0.05,
    "CZ": 0.04,
    "IT": 0.04,
    "ES": 0.04,
    "BE": 0.03,
    "SE": 0.02,
    "DK": 0.02,
}

CITIES_DE = [
    "Berlin", "München", "Hamburg", "Köln", "Frankfurt",
    "Düsseldorf", "Stuttgart", "Dortmund", "Essen", "Leipzig",
    "Bremen", "Dresden", "Hannover", "Nürnberg", "Bonn",
]

DEVICE_WEIGHTS = {"mobile": 0.55, "desktop": 0.35, "tablet": 0.10}


def generate_users(count: int, start_date: date, end_date: date) -> list[User]:
    """Generate a list of users."""
    
    users = []
    countries = list(COUNTRY_WEIGHTS.keys())
    country_probs = list(COUNTRY_WEIGHTS.values())
    devices = list(DEVICE_WEIGHTS.keys())
    device_probs = list(DEVICE_WEIGHTS.values())
    date_range = (end_date - start_date).days
    
    for _ in range(count):
        country = random.choices(countries, weights=country_probs, k=1)[0]
        fake = fake_de if country == "DE" else fake_en
        
        reg_date = start_date + timedelta(days=random.randint(0, date_range))
        
        user = User(
            user_id=uuid4(),
            email=fake.unique.email(),
            first_name=fake.first_name(),
            last_name=fake.last_name(),
            country=country,
            city=random.choice(CITIES_DE) if country == "DE" else fake.city(),
            registration_date=reg_date,
            birth_date=fake.date_of_birth(minimum_age=18, maximum_age=70),
            gender=random.choice(["M", "F", "X"]),
            device_type=random.choices(devices, weights=device_probs, k=1)[0],
            segment=UserSegment.NEW,  # Will be recalculated after order generation
            clv_tier=CLVTier.BRONZE,  # Will be recalculated
            is_active=random.random() > 0.05,
        )
        users.append(user)
    
    return users