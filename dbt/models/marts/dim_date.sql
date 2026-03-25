-- Dimension: Date (from raw.dim_date, unchanged)

SELECT
    date_key,
    full_date,
    day_of_week,
    TRIM(day_name) AS day_name,
    day_of_month,
    day_of_year,
    week_of_year,
    month_number,
    TRIM(month_name) AS month_name,
    quarter,
    year,
    is_weekend,
    is_holiday_de,
    holiday_name_de,
    
    -- Additional fields for Power BI
    year || '-Q' || quarter AS year_quarter,
    year || '-' || LPAD(month_number::TEXT, 2, '0') AS year_month,
    CASE WHEN is_weekend OR is_holiday_de THEN TRUE ELSE FALSE END AS is_non_working_day

FROM {{ source('raw', 'dim_date') }}
