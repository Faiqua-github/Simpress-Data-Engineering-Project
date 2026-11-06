
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='CARRIER_KEY',
        on_schema_change='sync_all_columns'
    )
}}

WITH source_data AS (

    SELECT

        MD5(To_Varchar(carrier_key)) as carrier_sk,
        CARRIER_KEY,
        NULLIF(TRIM(CARRIER_CODE), '') AS CARRIER_CODE,
        NULLIF(TRIM(CARRIER_NAME), '') AS CARRIER_NAME,
        INITCAP(NULLIF(TRIM(SERVICE_TYPE), '')) AS SERVICE_TYPE,
        UPPER(NULLIF(TRIM(COUNTRY), '')) AS COUNTRY,
        UPPER(NULLIF(TRIM(IS_ACTIVE), '')) AS IS_ACTIVE,
        SOURCE_FILE,
        FILE_ROW_NUMBER,
        INGESTED_AT

    FROM {{ source('simpress_raw', 'RAW_CARRIER') }}

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

Validation as (
Select * from source_data
where CARRIER_KEY is not null
AND
    CARRIER_CODE is not null 
AND
    Service_type in ('Express','Ground','Postal','Last Mile','Domestic','International','Air Cargo','Ocean Freight','Rail Cargo','Same Day','Cross Border')
),

deduplicated AS (

    SELECT *
    FROM Validation
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY CARRIER_KEY
        ORDER BY INGESTED_AT DESC, FILE_ROW_NUMBER DESC
    ) = 1

)

SELECT *
FROM deduplicated
