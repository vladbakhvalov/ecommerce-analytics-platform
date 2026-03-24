from datetime import date, datetime
from enum import Enum
from pydantic import BaseModel, Field
from uuid import UUID, uuid4


class CampaignChannel(str, Enum):
    GOOGLE_ADS = "google_ads"
    FACEBOOK = "facebook"
    INSTAGRAM = "instagram"
    EMAIL = "email"
    TIKTOK = "tiktok"
    AFFILIATE = "affiliate"
    ORGANIC = "organic"


class CampaignType(str, Enum):
    AWARENESS = "awareness"
    CONSIDERATION = "consideration"
    CONVERSION = "conversion"
    RETENTION = "retention"


class Campaign(BaseModel):
    """Model of advertising campaign."""
    
    campaign_id: UUID = Field(default_factory=uuid4)
    name: str
    channel: CampaignChannel
    campaign_type: CampaignType
    start_date: date
    end_date: date | None = None
    daily_budget: float = Field(gt=0)
    is_active: bool = True


class CampaignDailyStats(BaseModel):
    """Daily statistics of a campaign."""
    
    campaign_id: UUID
    stat_date: date
    impressions: int = Field(ge=0)
    clicks: int = Field(ge=0)
    cost: float = Field(ge=0)
    conversions: int = Field(ge=0)
    revenue: float = Field(ge=0)
    
    @property
    def ctr(self) -> float:
        return self.clicks / self.impressions if self.impressions > 0 else 0
    
    @property
    def cpa(self) -> float:
        return self.cost / self.conversions if self.conversions > 0 else 0
    
    @property
    def roas(self) -> float:
        return self.revenue / self.cost if self.cost > 0 else 0