
{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='STATUS_KEY',
        on_schema_change='sync_all_columns'
    )
}}

WITH source_data AS (

    SELECT
        MD5(TO_VARCHAR(STATUS_KEY)) AS STATUS_SK,
        STATUS_KEY,
        CARRIER_KEY,
        INITCAP(NULLIF(TRIM(CARRIER_STATUS), '')) AS CARRIER_STATUS,
        INITCAP(NULLIF(TRIM(MASTER_STATUS), '')) AS MASTER_STATUS,
        SOURCE_FILE,
        FILE_ROW_NUMBER,
        INGESTED_AT

    FROM {{ source('simpress_raw', 'RAW_STATUS') }}

    {% if is_incremental() %}
        WHERE INGESTED_AT >= (
            SELECT COALESCE(
                DATEADD(hour, -1, MAX(INGESTED_AT)),
                '1900-01-01'::TIMESTAMP_NTZ
            )
            FROM {{ this }}
        )
    {% endif %}

),

deduplicated AS (

    SELECT *
    FROM source_data
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY STATUS_KEY
        ORDER BY INGESTED_AT DESC, FILE_ROW_NUMBER DESC
    ) = 1

)

SELECT *
FROM deduplicated
