
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='SHIPMENT_ID',
        on_schema_change='sync_all_columns'
    )
}}

WITH source_data AS (

    SELECT
        SHIPMENT_ID,
        TRY_CAST(CARRIER_KEY AS NUMBER(38,0)) AS CARRIER_KEY,
        TRY_CAST(PRODUCT_KEY AS NUMBER(38,0)) AS PRODUCT_KEY,
        TRY_CAST(DESTINATION_KEY AS NUMBER(38,0)) AS DESTINATION_KEY,
        TRY_CAST(STATUS_KEY AS NUMBER(38,0)) AS STATUS_KEY,

        TRY_TO_DATE(SHIPMENT_DATE) AS SHIPMENT_DATE,
        TRY_TO_DATE(ESTIMATED_DELIVERY_DATE)
            AS ESTIMATED_DELIVERY_DATE,
        TRY_TO_DATE(ACTUAL_DELIVERY_DATE)
            AS ACTUAL_DELIVERY_DATE,

        TRY_CAST(DELIVERY_DURATION_DAYS AS NUMBER(10,2))
            AS DELIVERY_DURATION_DAYS,
        TRY_CAST(DELIVERY_ATTEMPTS AS NUMBER(10,0))
            AS DELIVERY_ATTEMPTS,
        TRY_CAST(SHIPMENT_DISTANCE_KMS AS NUMBER(10,2))
            AS SHIPMENT_DISTANCE_KMS,

        LOAD_TIMESTAMP,
        SOURCE_FILE_NAME,

        SOURCE_FILE,
        FILE_ROW_NUMBER,
        INGESTED_AT

    FROM {{ source('simpress_raw', 'RAW_SHIPMENT') }}

    {% if is_incremental() %}
        WHERE INGESTED_AT >= (
            SELECT COALESCE(
                DATEADD(hour, -1, MAX(INGESTED_AT)),
                '2026-01-01'::TIMESTAMP_NTZ
            )
            FROM {{ this }}
        )
    {% endif %}

),

deduplicated AS (

    SELECT * FROM source_data

    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY SHIPMENT_ID
        ORDER BY
            INGESTED_AT DESC,
            FILE_ROW_NUMBER DESC
    ) = 1

)

SELECT * FROM deduplicated
