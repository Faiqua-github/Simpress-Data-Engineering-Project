{{
config(
    materialized='incremental',
    Incremental_strategy='merge',
    unique_key='PRODUCT_KEY',
    on_schema_change='sync_all_columns'
    )
}}

With Source_Data as(
    SELECT
    MD5(To_varchar(product_key)) as product_sk,
    PRODUCT_KEY,
    NULLIF(TRIM(PRODUCT_CODE), '') AS PRODUCT_CODE,
    INITCAP(NULLIF(TRIM(PRODUCT_NAME), '')) AS PRODUCT_NAME,
    FULFILLER_ID,
    INITCAP(NULLIF(TRIM(CATEGORY), '')) AS CATEGORY,
    SOURCE_FILE,
    FILE_ROW_NUMBER,
    INGESTED_AT
    FROM {{ source('simpress_raw','RAW_PRODUCT') }}

{% if is_incremental() %}
    WHERE INGESTED_AT >= (
        SELECT COALESCE(DATEADD(hour, -1, MAX(INGESTED_AT)), '2026-01-01'::TIMESTAMP_NTZ)
        FROM {{ this }}
    )
{% endif %}

),

Deduplication as (
    SELECT *
    FROM Source_Data
    QUALIFY ROW_NUMBER() OVER(
        PARTITION BY PRODUCT_KEY
        ORDER BY INGESTED_AT DESC, FILE_ROW_NUMBER DESC
    ) = 1
)

Select * from Deduplication