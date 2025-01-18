with dim_customers as (
    select *
    from {{ ref('dim_customers_snapshot') }}
),

dim_hotels as (
    select *
    from {{ ref('dim_hotels_snapshot') }}
),

stg_hotel_bookings as (
    select
        trip_id as trip_id_nk,
        customer_id,
        hotel_id,
        check_in_date,
        check_out_date,
        price,
        breakfast_included
    from
        {{ source("dwh", "hotel_bookings") }}
),

dim_date as (
    select *
    from 
    {{ ref('dim_date') }}
),

final_hotel_bookings as (
    select
        {{ dbt_utils.generate_surrogate_key(['trip_id_nk']) }} as trip_id_sk,
        dc.customer_id_sk,
        dh.hotel_id_sk,
        check_in_date.date_id as check_in_date_id,
        check_out_date.date_id as check_out_date_id,
        sh.price,
        sh.breakfast_included
    from
        stg_hotel_bookings sh
    join
        dim_customers dc
        on dc.customer_id_nk = sh.customer_id
    join
        dim_hotels dh 
        on dh.hotel_id_nk = sh.hotel_id
    join
        dim_date check_in_date
        on check_in_date.date_actual = DATE(sh.check_in_date)
    join
        dim_date check_out_date
        on check_out_date.date_actual = DATE(sh.check_out_date)
)

select * from final_hotel_bookings
