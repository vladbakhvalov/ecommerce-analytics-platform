-- DIM_DATE Is a Calendar table (1 January 2023 – 31 December 2026)
-- Includes German public holidays for NRW
CREATE TABLE
    IF NOT EXISTS raw.dim_date (
        date_key INTEGER PRIMARY KEY, -- YYYYMMDD
        full_date DATE NOT NULL UNIQUE,
        day_of_week INTEGER NOT NULL, -- 1 (Mon) — 7 (Sun)
        day_name VARCHAR(10) NOT NULL,
        day_of_month INTEGER NOT NULL,
        day_of_year INTEGER NOT NULL,
        week_of_year INTEGER NOT NULL, -- ISO week
        month_number INTEGER NOT NULL,
        month_name VARCHAR(10) NOT NULL,
        quarter INTEGER NOT NULL,
        year INTEGER NOT NULL,
        is_weekend BOOLEAN NOT NULL,
        is_holiday_de BOOLEAN NOT NULL DEFAULT FALSE,
        holiday_name_de VARCHAR(100)
    );

-- DATE GENERATION: 2023-01-01 — 2026-12-31
INSERT INTO raw.dim_date (
    date_key, full_date, day_of_week, day_name, day_of_month,
    day_of_year, week_of_year, month_number, month_name,
    quarter, year, is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER AS date_key,
    d AS full_date,
    EXTRACT(ISODOW FROM d)::INTEGER AS day_of_week,
    TO_CHAR(d, 'Day') AS day_name,
    EXTRACT(DAY FROM d)::INTEGER AS day_of_month,
    EXTRACT(DOY FROM d)::INTEGER AS day_of_year,
    EXTRACT(WEEK FROM d)::INTEGER AS week_of_year,
    EXTRACT(MONTH FROM d)::INTEGER AS month_number,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(QUARTER FROM d)::INTEGER AS quarter,
    EXTRACT(YEAR FROM d)::INTEGER AS year,
    EXTRACT(ISODOW FROM d) IN (6, 7) AS is_weekend
FROM generate_series('2023-01-01'::date, '2026-12-31'::date, '1 day'::interval) AS d
ON CONFLICT (date_key) DO NOTHING;

-- German public holidays NRW (fixed)
UPDATE raw.dim_date SET is_holiday_de = TRUE, holiday_name_de = 'Neujahr'
WHERE month_number = 1 AND day_of_month = 1;

UPDATE raw.dim_date SET is_holiday_de = TRUE, holiday_name_de = 'Tag der Arbeit'
WHERE month_number = 5 AND day_of_month = 1;

UPDATE raw.dim_date SET is_holiday_de = TRUE, holiday_name_de = 'Tag der Deutschen Einheit'
WHERE month_number = 10 AND day_of_month = 3;

UPDATE raw.dim_date SET is_holiday_de = TRUE, holiday_name_de = 'Allerheiligen (NRW)'
WHERE month_number = 11 AND day_of_month = 1;

UPDATE raw.dim_date SET is_holiday_de = TRUE, holiday_name_de = '1. Weihnachtstag'
WHERE month_number = 12 AND day_of_month = 25;

UPDATE raw.dim_date SET is_holiday_de = TRUE, holiday_name_de = '2. Weihnachtstag'
WHERE month_number = 12 AND day_of_month = 26;