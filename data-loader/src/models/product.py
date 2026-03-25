from datetime import datetime, timezone
from enum import Enum
from pydantic import BaseModel, Field
from uuid import UUID, uuid4


class PriceSegment(str, Enum):
    BUDGET = "budget"        # < 20€
    STANDARD = "standard"    # 20-50€
    PREMIUM = "premium"      # 50-150€
    LUXURY = "luxury"        # > 150€


class Product(BaseModel):
    """Model of product from ShopFlow."""
    
    product_id: UUID = Field(default_factory=uuid4)
    name: str
    category: str
    subcategory: str
    brand: str
    price: float = Field(gt=0)
    cost: float = Field(gt=0, description="Cost")
    price_segment: PriceSegment
    rating: float = Field(ge=1.0, le=5.0)
    reviews_count: int = Field(ge=0)
    stock_quantity: int = Field(ge=0)
    is_active: bool = True
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    
    @property
    def margin(self) -> float:
        return (self.price - self.cost) / self.price