from datetime import datetime
from enum import Enum
from pydantic import BaseModel, Field
from uuid import UUID, uuid4


class EventType(str, Enum):
    PAGE_VIEW = "page_view"
    PRODUCT_VIEW = "product_view"
    ADD_TO_CART = "add_to_cart"
    REMOVE_FROM_CART = "remove_from_cart"
    BEGIN_CHECKOUT = "begin_checkout"
    PURCHASE = "purchase"
    SEARCH = "search"
    SIGNUP = "signup"
    LOGIN = "login"


class Event(BaseModel):
    """Model of user event."""
    
    event_id: UUID = Field(default_factory=uuid4)
    user_id: UUID
    event_type: EventType
    event_timestamp: datetime
    product_id: UUID | None = None
    page_url: str | None = None
    device_type: str = Field(description="mobile|desktop|tablet")
    session_id: UUID = Field(default_factory=uuid4)
    country: str = Field(max_length=2)