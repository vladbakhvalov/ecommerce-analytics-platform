from datetime import datetime
from enum import Enum
from pydantic import BaseModel, Field
from uuid import UUID, uuid4


class OrderStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"
    REFUNDED = "refunded"


class OrderItem(BaseModel):
    """Position of an order."""
    
    order_item_id: UUID = Field(default_factory=uuid4)
    order_id: UUID
    product_id: UUID
    quantity: int = Field(ge=1)
    unit_price: float = Field(gt=0)
    discount_pct: float = Field(ge=0, le=1, default=0.0)
    
    @property
    def line_total(self) -> float:
        return self.quantity * self.unit_price * (1 - self.discount_pct)


class Order(BaseModel):
    """Model of order from ShopFlow."""
    
    order_id: UUID = Field(default_factory=uuid4)
    user_id: UUID
    order_date: datetime
    status: OrderStatus
    payment_method: str = Field(description="credit_card|paypal|bank_transfer|klarna")
    shipping_country: str = Field(max_length=2)
    campaign_id: UUID | None = None
    items: list[OrderItem] = []
    
    @property
    def total_amount(self) -> float:
        return sum(item.line_total for item in self.items)