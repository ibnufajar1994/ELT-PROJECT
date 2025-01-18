{% snapshot dim_customers_snapshot %}

{{
    config(
        target_database='dwh',
        target_schema='final',
        unique_key='customer_id_sk',

        strategy='check',
        check_cols=[
            'customer_country',
            'customer_phone_number'
        ]
    )
}}

with stg_customers as (
    select *
    from
        {{ source("dwh","customers") }}
),

dim_customers as (
    select 
        customer_id as customer_id_nk,
        customer_first_name,
        customer_family_name,
        customer_gender,
        customer_birth_date,
        customer_country,
        customer_phone_number
    from stg_customers

),

final_dim_customers as (
    select
        {{ dbt_utils.generate_surrogate_key(['customer_id_nk']) }} as customer_id_sk,
        *
    from
        dim_customers
)

select * from final_dim_customers

{% endsnapshot %}
