{% snapshot dim_hotels_snapshot %}

{{
    config(
        target_database='dwh',
        target_schema='final',
        unique_key='hotel_id_sk',

        strategy='check',
        check_cols=[
            "hotel_name",
            "hotel_address",
            "hotel_score"
        ]
    )
}}

with stg_hotels as (
    select *
    from {{ source("dwh","hotels") }}
),

dim_hotels as (
    select
        "hotel_id" as hotel_id_nk,
        "hotel_name",
        "hotel_address",
        "city",
        "country",
        "hotel_score"

    from
        stg_hotels

),

final_dim_hotels as (
    select
     {{ dbt_utils.generate_surrogate_key( ["hotel_id_nk"] ) }} as hotel_id_sk,
     *
    from
        dim_hotels
)

select * from final_dim_hotels

{% endsnapshot %}

