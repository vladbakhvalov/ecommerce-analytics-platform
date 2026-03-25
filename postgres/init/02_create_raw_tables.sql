-- RAW tables for data-loader

CREATE TABLE IF NOT EXISTS raw.users (
    user_id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    country CHAR(2) NOT NULL,
    city VARCHAR(255) NOT NULL,
    registration_date DATE NOT NULL,
    birth_date DATE,
    gender CHAR(1),
    device_type VARCHAR(10) NOT NULL,
    segment VARCHAR(20) NOT NULL DEFAULT 'new',
    clv_tier VARCHAR(10) NOT NULL DEFAULT 'bronze',
    total_orders INTEGER NOT NULL DEFAULT 0,
    total_revenue NUMERIC(12, 2) NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_country ON raw.users (country);
CREATE INDEX IF NOT EXISTS idx_users_segment ON raw.users (segment);
CREATE INDEX IF NOT EXISTS idx_users_registration_date ON raw.users (registration_date);

CREATE TABLE IF NOT EXISTS raw.products (
    product_id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price > 0),
    cost NUMERIC(10, 2) NOT NULL CHECK (cost > 0),
    price_segment VARCHAR(10) NOT NULL,
    rating NUMERIC(2, 1) CHECK (rating BETWEEN 1.0 AND 5.0),
    reviews_count INTEGER NOT NULL DEFAULT 0,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_category ON raw.products (category);
CREATE INDEX IF NOT EXISTS idx_products_price_segment ON raw.products (price_segment);

CREATE TABLE IF NOT EXISTS raw.campaigns (
    campaign_id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    channel VARCHAR(30) NOT NULL,
    campaign_type VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    daily_budget NUMERIC(10, 2) NOT NULL CHECK (daily_budget > 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw.orders (
    order_id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES raw.users (user_id),
    order_date TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    shipping_country CHAR(2) NOT NULL,
    campaign_id UUID REFERENCES raw.campaigns (campaign_id),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_orders_user_id ON raw.orders (user_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_date ON raw.orders (order_date);
CREATE INDEX IF NOT EXISTS idx_orders_status ON raw.orders (status);
CREATE INDEX IF NOT EXISTS idx_orders_campaign_id ON raw.orders (campaign_id);

CREATE TABLE IF NOT EXISTS raw.order_items (
    order_item_id UUID PRIMARY KEY,
    order_id UUID NOT NULL REFERENCES raw.orders (order_id),
    product_id UUID NOT NULL REFERENCES raw.products (product_id),
    quantity INTEGER NOT NULL CHECK (quantity >= 1),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
    discount_pct NUMERIC(3, 2) NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 1),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON raw.order_items (order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON raw.order_items (product_id);

CREATE TABLE IF NOT EXISTS raw.events (
    event_id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES raw.users (user_id),
    event_type VARCHAR(30) NOT NULL,
    event_timestamp TIMESTAMP NOT NULL,
    product_id UUID REFERENCES raw.products (product_id),
    page_url VARCHAR(500),
    device_type VARCHAR(10) NOT NULL,
    session_id UUID NOT NULL,
    country CHAR(2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_user_id ON raw.events (user_id);
CREATE INDEX IF NOT EXISTS idx_events_event_type ON raw.events (event_type);
CREATE INDEX IF NOT EXISTS idx_events_timestamp ON raw.events (event_timestamp);
CREATE INDEX IF NOT EXISTS idx_events_product_id ON raw.events (product_id);

CREATE TABLE IF NOT EXISTS raw.campaign_daily_stats (
    campaign_id UUID NOT NULL REFERENCES raw.campaigns (campaign_id),
    stat_date DATE NOT NULL,
    impressions INTEGER NOT NULL DEFAULT 0,
    clicks INTEGER NOT NULL DEFAULT 0,
    cost NUMERIC(10, 2) NOT NULL DEFAULT 0,
    conversions INTEGER NOT NULL DEFAULT 0,
    revenue NUMERIC(12, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (campaign_id, stat_date)
);

CREATE INDEX IF NOT EXISTS idx_campaign_stats_date ON raw.campaign_daily_stats (stat_date);