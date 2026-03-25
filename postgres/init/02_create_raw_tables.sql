-- RAW Tables for data-loader
-- USERS
CREATE TABELE IF NOT EXISTS raw.users (
    user_id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(255) NOT NULL,
    laste_name VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    registration_date DATE NOT NULL,
    birth_date DATE NOT NULL,
    gender CHAR(1) NOT NULL, -- M/F/X
    device_type VARCHAR(10) NOT NULL, -- mobile/desktop/tablet   
    segment VARCHAR(20) NOT NULL DEFAULT 'new',
    clv_tier VARCHAR(10) NOT NULL DEFAULT 'bronze',
    total_orders INTEGER NOT NULL DEFAULT 0,
    total_revenue NUMERIC(12, 2) NOT NULL DEFAULT 0 is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW ()
);

CREATE INDEX idx_users_country ON raw.users (country);

CREATE INDEX idx_users_segment ON raw.users (segment);

CREATE INDEX idx_users_registration_date ON raw.users (registration_date);

-- PRODUCTS
CREATE TABLE
    IF NOT EXISTS raw.products (
        product_id UUID PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        category VARCHAR(100) NOT NULL,
        subcategory VARCHAR(100) NOT NULL,
        brand VARCHAR(100) NOT NULL,
        price NUMERIC(10, 2) NOT NULL CHECK (price > 0),
        cost NUMERIC(10, 2) NOT NULL CHECK (cost > 0),
        price_segment VARCHAR(10) NOT NULL, -- budget/standart/premium/luxury
        rating NUMERIC(2, 1) CHECK (rating BETWEEN 1.0 AND 5.0),
        reviews_cout INTEGER NOT NULL DEFAULT 0,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMP NOT NULL DEFAULT NOW ()
    );

CREATE INDEX idx_products_category ON raw.products (category);

CREATE INDEX idx_products_price_segment ON raw.products (price_segment);

-- ORDERS
CREATE TABLE
    IF NOT EXISTS raw.orders (
        order_id UUID PRIMARY KEY,
        user_id UUID NOT NULL REFERENCES raw.users (user_id),
        order_date TIMESTAMP NOT NULL,
        status VARCHAR(20) NOT NULL, -- pending/confirmed/shipped/delivered/cancelled/refunded
        payment_method VARCHAR(20) NOT NULL, -- credit_card/paypal/bank_transfer/klarna
        shipping_country CHAR(2) NOT NULL,
        campaign_id UUID, -- Nullable: not all orders are from advertising
        created_at TIMESTAMP NOT NULL DEFAULT NOW ()
    );

CREATE INDEX idx_orders_user_id ON raw.orders (user_id);

CREATE INDEX idx_orders_order_date ON raw.orders (order_date);

CREATE INDEX idx_orders_status ON raw.orders (status);

CREATE INDEX idx_orders_campaign_id ON raw.orders (campaign_id);

-- ORDERS ITEMS
CREATE TABLE
    IF NOT EXISTS raw.order_items (
        order_item_id UUID PRIMARY KEY,
        order_id UUID NOT NULL REFERENCES raw.orders (order_id),
        product_id UUID NOT NULL REFERENCES raw.products (product_id),
        quantity INTEGER NOT NULL CHECK (quantity >= 1),
        unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price > 0),
        discount_pct NUMERIC(3, 2) NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 1),
        created_at TIMESTAMP NOT NULL DEFAULT NOW ()
    );

CREATE INDEX idx_order_items_order_id ON raw.order_items (order_id);

CREATE INDEX idx_order_items_product_id ON raw.order_items (product_id);

-- USERS EVENTS
CREATE TABLE
    IF NOT EXISTS raw.events (
        event_id UUID PRIMARY KEY,
        user_id UUID NOT NULL,
        event_type VARCHAR(30) NOT NULL,
        event_timestamp TIMESTAMP NOT NULL,
        product_id UUID, -- Nullable: not all events are related to a product
        page_url VARCHAR(500),
        device_type VARCHAR(10) NOT NULL,
        session_id UUID NOT NULL,
        country CHAR(2) NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT NOW ()
    );

CREATE INDEX idx_events_user_id ON raw.events (user_id);

CREATE INDEX idx_events_event_type ON raw.events (event_type);

CREATE INDEX idx_events_timestamp ON raw.events (event_timestamp);

CREATE INDEX idx_events_product_id ON raw.events (product_id);

-- CAMPAIGNS
CREATE TABLE
    IF NOT EXISTS raw.campaigns (
        campaign_id UUID PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        channel VARCHAR(30) NOT NULL, -- google_ads/facebook/instagram/email/tiktok/affiliate/organic
        campaign_type VARCHAR(20) NOT NULL, -- awareness/consideration/conversion/retention
        start_date DATE NOT NULL,
        end_date DATE,
        daily_budget NUMERIC(10, 2) NOT NULL CHECK (daily_budget > 0),
        is_active BOOLEAN NOT NULL DEFAULT TRUE,
        created_at TIMESTAMP NOT NULL DEFAULT NOW ()
    );

-- DAILY CAMPAIGN PERFORMANCE
CREATE TABLE
    IF NOT EXISTS raw.campaign_daily_stats (
        campaign_id UUID NOT NULL REFERENCES raw.campaigns (campaign_id),
        stat_date DATE NOT NULL,
        impressions INTEGER NOT NULL DEFAULT 0,
        clicks INTEGER NOT NULL DEFAULT 0,
        cost NUMERIC(10, 2) NOT NULL DEFAULT 0,
        conversions INTEGER NOT NULL DEFAULT 0,
        revenue NUMERIC(12, 2) NOT NULL DEFAULT 0,
        created_at TIMESTAMP NOT NULL DEFAULT NOW (),
        PRIMARY KEY (campaign_id, stat_date)
    );

CREATE INDEX idx_campaign_stats_date ON raw.campaign_daily_stats (stat_date);