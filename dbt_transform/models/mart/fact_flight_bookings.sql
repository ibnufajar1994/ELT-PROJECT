
-- SQL statement Anda
-- SQL statement Anda

with dim_aircrafts as (
    select *
    from
        {{ ref("dim_aircrafts") }}
),

dim_airports as (
    select *
    from
        {{ ref("dim_airports") }}
),

dim_airlines as (
    select *
    from
        {{ ref("dim_airlines_snapshot") }}
),

dim_customers as (
    select *
    from
        {{ ref("dim_customers_snapshot") }}
),

stg_flight_booking as (
    select
        trip_id as trip_id_nk,
        flight_number,
        seat_number,
        customer_id,
        airline_id,
        aircraft_id,
        airport_src,
        airport_dst,
        departure_time,
        departure_date,
        flight_duration,
        travel_class,
        price
    from
        {{source("dwh","flight_bookings")}}
),

dim_date as (
    select *
    from 
        {{ ref('dim_date') }}
),

dim_time as (
    select *
    from 
        {{ ref('dim_time') }}
),

final_flight_bookings as (
    SELECT
        -- Generate surrogate key untuk fact table
        {{ dbt_utils.generate_surrogate_key(["trip_id_nk", "flight_number", "seat_number"]) }} as trip_id_sk,
        da1.aircraft_id_sk,
        da2.airline_id_sk,
        src_airport.airport_id_sk as departure_airport_sk,
        dst_airport.airport_id_sk as arrival_airport_sk,
        dc.customer_id_sk,
        dd.date_id as departure_date_id,
        dt.time_id as departure_time_id,
        flight_duration,
        travel_class,
        price

    from
        stg_flight_booking sf 
    -- Join dengan dimensi aircraft
    join
        dim_aircrafts da1
        on da1.aircraft_id_nk = sf.aircraft_id
    -- Join dengan dimensi airline
    join
        dim_airlines da2
        on da2.airline_id_nk = sf.airline_id
    -- Join dengan dimensi airport untuk departure
    join
        dim_airports src_airport
        on src_airport.airport_id_nk = sf.airport_src
    -- Join dengan dimensi airport untuk arrival
    join
        dim_airports dst_airport
        on dst_airport.airport_id_nk = sf.airport_dst
    -- Join dengan dimensi customer
    join
        dim_customers dc
        on dc.customer_id_nk = sf.customer_id
    -- Join dengan dimensi date
    join
        dim_date dd
        on dd.date_actual = DATE(sf.departure_date)
    -- Join dengan dimensi time    
    join   
        dim_time dt
        on dt.time_actual::time = sf.departure_time::time
)

select * from final_flight_bookings