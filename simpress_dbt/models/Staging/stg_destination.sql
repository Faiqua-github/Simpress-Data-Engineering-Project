{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key='Destination_Key',
        on_schema_change='sync_all_columns'
    )
}}

With Source_Data as(

    Select
        MD5(To_varchar(destination_key)) as destination_sk,
        Destination_key,
        customer_id,
        Nullif(TRIM(ADDRESS_LINE_1), '') AS ADDRESS_LINE_1,
        Nullif(TRIM(POSTAL_CODE), '') AS POSTAL_CODE,
        Initcap(Nullif(TRIM(CITY), '')) AS CITY,
        Initcap(Nullif(TRIM(STATE), '')) AS STATE,
        Upper(Nullif(TRIM(COUNTRY), '')) AS COUNTRY,
        Source_file,
        file_row_number,
        ingested_at
    FROM {{ source('simpress_raw', 'RAW_DESTINATION') }}

    {% if is_incremental() %}
        where ingested_at >= (
            Select coalesce(dateadd(hour, -1, max(ingested_at)), '2026-01-01'::timestamp_ntz )
        from {{ this }}
        )

    {% endif %}
),

Dedupication as (
    Select * from Source_Data
    Qualify row_number() Over(
        Partition by Destination_key
        Order by ingested_at desc, file_row_number desc
    ) = 1
)

Select * From Dedupication