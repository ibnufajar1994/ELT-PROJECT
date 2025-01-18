{% snapshot dim_airlines_snapshot %}

{{
    config(
        target_database='dwh',
        target_schema='final',
        unique_key='airline_id_sk',
        strategy='check',
        check_cols=['airline_name', 'country', 'alias']
    )
}}

with stg_airlines as (
    select *
    from {{ source("dwh","airlines") }}
),

dim_airlines as (
    select
        "airline_id" as airline_id_nk,
        "airline_name",
        "country",
        "airline_icao",
        "airline_iata",
        "alias"
    from stg_airlines
),

final_dim_airlines as (
    select
        {{ dbt_utils.generate_surrogate_key(['airline_id_nk']) }} as airline_id_sk,
        *
    from dim_airlines
)

select * from final_dim_airlines

{% endsnapshot %}