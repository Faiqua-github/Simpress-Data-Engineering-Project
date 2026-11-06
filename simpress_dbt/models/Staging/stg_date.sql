-- The main purpose of this model is to create a Date Dimension table containing calendar information for every date on which a shipment-related event can occur.


{{
    config(
        materialized='table'
    )
}}

WITH shipment_date_range AS (

--Generate every date between the minimum and maximum

    SELECT
        LEAST(
            MIN(SHIPMENT_DATE),
            MIN(ESTIMATED_DELIVERY_DATE),
            MIN(ACTUAL_DELIVERY_DATE)
        ) AS MIN_DATE,

        GREATEST(
            MAX(SHIPMENT_DATE),
            MAX(ESTIMATED_DELIVERY_DATE),
            MAX(ACTUAL_DELIVERY_DATE)
        ) AS MAX_DATE

    FROM {{ ref('stg_shipment') }}

),

date_spine AS (

    SELECT
        DATEADD(
            DAY,
            SEQ4(),
            MIN_DATE
        )::DATE AS FULL_DATE

    FROM shipment_date_range, TABLE(GENERATOR(ROWCOUNT => 10000))

    WHERE DATEADD(DAY, SEQ4(), MIN_DATE) <= MAX_DATE

),

date_dimension AS (

    SELECT
        -- Date surrogate key in YYYYMMDD format
        TO_NUMBER(TO_CHAR(FULL_DATE, 'YYYYMMDD')) AS DATE_SK,

        FULL_DATE,

        -- Calendar attributes
        YEAR(FULL_DATE) AS YEAR,
        QUARTER(FULL_DATE) AS QUARTER,
        MONTH(FULL_DATE) AS MONTH,
        MONTHNAME(FULL_DATE) AS MONTH_NAME,
        DAY(FULL_DATE) AS DAY,
        DAYNAME(FULL_DATE) AS DAY_NAME,
        DAYOFWEEK(FULL_DATE) AS DAY_OF_WEEK,

        -- Week and quarter details
        WEEKOFYEAR(FULL_DATE) AS WEEK_OF_YEAR,
        DAYOFYEAR(FULL_DATE) AS DAY_OF_YEAR,

        -- Weekend indicator
        CASE
            WHEN DAYOFWEEKISO(FULL_DATE) IN (6, 7)
            THEN TRUE
            ELSE FALSE
        END AS IS_WEEKEND

    FROM date_spine

)

SELECT *
FROM date_dimension
