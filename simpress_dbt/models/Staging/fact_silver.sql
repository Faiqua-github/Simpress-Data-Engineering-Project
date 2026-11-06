
{{
    config(
        materialized='view',
        unique_key='SHIPMENT_ID',
        on_schema_change='sync_all_columns'
    )
}}

WITH shipment_data AS (

    SELECT *
    FROM {{ ref('stg_shipment') }}

),

fact_shipments AS (

    SELECT
        -- Shipment identifier
        s.SHIPMENT_ID,

        -- Foreign keys
        s.CARRIER_KEY,
        s.PRODUCT_KEY,
        s.DESTINATION_KEY,
        s.STATUS_KEY,

        -- surrogate keys from dimension tables
        c.CARRIER_SK,
        d.DESTINATION_SK,
        p.PRODUCT_SK,  
        st.STATUS_SK,

        -- Shipment dates
        s.SHIPMENT_DATE,
        s.ESTIMATED_DELIVERY_DATE,
        s.ACTUAL_DELIVERY_DATE,

        -- Shipment measures
        s.DELIVERY_DURATION_DAYS,
        s.DELIVERY_ATTEMPTS,
        s.SHIPMENT_DISTANCE_KMS,

        -- Derived delivery indicators
        CASE
            WHEN s.ACTUAL_DELIVERY_DATE IS NOT NULL
            THEN 1 ELSE 0
        END AS IS_DELIVERED,

        CASE
            WHEN s.ACTUAL_DELIVERY_DATE IS NULL
            THEN 1 ELSE 0
        END AS IS_PENDING_DELIVERY,

        CASE
            WHEN s.ACTUAL_DELIVERY_DATE >
                 s.ESTIMATED_DELIVERY_DATE
            THEN 1 ELSE 0
        END AS IS_DELIVERED_LATE,

        -- Carrier details
        c.CARRIER_CODE,
        c.CARRIER_NAME,
        c.SERVICE_TYPE,
        c.COUNTRY AS CARRIER_COUNTRY,
        c.IS_ACTIVE AS CARRIER_IS_ACTIVE,

        -- Product details
        p.PRODUCT_CODE,
        p.PRODUCT_NAME,
        p.CATEGORY AS PRODUCT_CATEGORY,
        p.FULFILLER_ID,

        -- Destination details
        d.CUSTOMER_ID,
        d.ADDRESS_LINE_1,
        d.POSTAL_CODE,
        d.CITY AS DESTINATION_CITY,
        d.STATE AS DESTINATION_STATE,
        d.COUNTRY AS DESTINATION_COUNTRY,

        -- Status details
        st.CARRIER_STATUS,
        st.MASTER_STATUS,

        -- Source metadata
        s.SOURCE_FILE,
        s.FILE_ROW_NUMBER,
        s.INGESTED_AT

    FROM shipment_data s

    LEFT JOIN {{ ref('stg_carrier') }} c
        ON s.CARRIER_KEY = c.CARRIER_KEY

    LEFT JOIN {{ ref('stg_product') }} p
        ON s.PRODUCT_KEY = p.PRODUCT_KEY

    LEFT JOIN {{ ref('stg_destination') }} d
        ON s.DESTINATION_KEY = d.DESTINATION_KEY

    LEFT JOIN {{ ref('stg_status') }} st
        ON s.STATUS_KEY = st.STATUS_KEY

)

SELECT *
FROM fact_shipments
