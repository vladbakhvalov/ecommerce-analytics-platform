import random
from datetime import date, timedelta
from uuid import uuid4

from src.models.campaign import (
    Campaign,
    CampaignChannel,
    CampaignDailyStats,
    CampaignType,
)

CAMPAIGN_NAME_PREFIXES = [
    "Spring", "Summer", "Autumn", "Winter", "Flash", "Weekend",
    "Holiday", "Black Friday", "Cyber Monday", "Back to School",
    "New Year", "Easter", "Prime", "Mega", "Super",
]

CAMPAIGN_NAME_SUFFIXES = [
    "Sale", "Deals", "Promo", "Blast", "Special", "Offer",
    "Campaign", "Push", "Launch", "Event",
]


def generate_campaigns(count: int, start_date: date, end_date: date) -> list[Campaign]:
    """Generate marketing campaigns."""

    campaigns: list[Campaign] = []
    channels = list(CampaignChannel)
    types = list(CampaignType)
    date_range = (end_date - start_date).days

    for _ in range(count):
        channel = random.choice(channels)
        camp_start = start_date + timedelta(days=random.randint(0, max(0, date_range - 30)))
        duration = random.randint(7, 90)
        camp_end = min(camp_start + timedelta(days=duration), end_date)

        name = f"{random.choice(CAMPAIGN_NAME_PREFIXES)} {random.choice(CAMPAIGN_NAME_SUFFIXES)} {channel.value.replace('_', ' ').title()}"

        campaign = Campaign(
            campaign_id=uuid4(),
            name=name,
            channel=channel,
            campaign_type=random.choice(types),
            start_date=camp_start,
            end_date=camp_end,
            daily_budget=round(random.uniform(50.0, 2000.0), 2),
            is_active=camp_end >= end_date or random.random() > 0.3,
        )
        campaigns.append(campaign)

    return campaigns


def generate_campaign_stats(
    campaigns: list[Campaign],
    start_date: date,
    end_date: date,
) -> list[CampaignDailyStats]:
    """Generate daily performance stats for each campaign."""

    stats: list[CampaignDailyStats] = []

    for campaign in campaigns:
        camp_start = max(campaign.start_date, start_date)
        camp_end = min(campaign.end_date or end_date, end_date)

        if camp_start > camp_end:
            continue

        day_count = (camp_end - camp_start).days + 1

        for day_offset in range(day_count):
            stat_date = camp_start + timedelta(days=day_offset)

            impressions = int(random.gauss(10000, 4000))
            impressions = max(100, impressions)

            ctr = random.uniform(0.005, 0.08)
            clicks = max(1, int(impressions * ctr))

            cost = round(min(campaign.daily_budget * random.uniform(0.6, 1.1), campaign.daily_budget), 2)

            conv_rate = random.uniform(0.01, 0.08)
            conversions = max(0, int(clicks * conv_rate))

            avg_order_value = random.uniform(30.0, 150.0)
            revenue = round(conversions * avg_order_value * random.uniform(0.8, 1.2), 2)

            stat = CampaignDailyStats(
                campaign_id=campaign.campaign_id,
                stat_date=stat_date,
                impressions=impressions,
                clicks=clicks,
                cost=cost,
                conversions=conversions,
                revenue=revenue,
            )
            stats.append(stat)

    return stats
