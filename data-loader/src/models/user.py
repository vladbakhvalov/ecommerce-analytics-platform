from datetime import date, datetime
from enum import Enum
from pydantic import BaseModel, EmailStr, Field
from uuid import UUID, uuid4


class UserSegment(str, Enum):
    NEW = "new"
    ACTIVE = "active"
    RETURNING = "returning"
    DORMANT = "dormant"
    VIP = "vip"


class CLVTier(str, Enum):
    BRONZE = "bronze"
    SILVER = "silver"
    GOLD = "gold"
    PLATINUM = "platinum"


class User(BaseModel):
    """Model of user from ShopFlow."""
    
    user_id: UUID = Field(default_factory=uuid4)
    email: EmailStr
    first_name: str
    last_name: str
    country: str = Field(max_length=2, description="ISO 3166-1 alpha-2")
    city: str
    registration_date: date
    birth_date: date | None = None
    gender: str | None = Field(None, pattern="^(M|F|X)$")
    device_type: str = Field(description="mobile|desktop|tablet")
    segment: UserSegment = UserSegment.NEW
    clv_tier: CLVTier = CLVTier.BRONZE
    total_orders: int = 0
    total_revenue: float = 0.0
    is_active: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)