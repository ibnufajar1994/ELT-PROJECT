with stg_dim_aircrats as (
    SELECT
        aircraft_id as aircraft_id_nk,
        aircraft_name,
        aircraft_iata,
        aircraft_icao
    
    FROM
        {{ source("dwh","aircrafts") }}
),

dim_aircrafts as (
    SELECT *
    FROM stg_dim_aircrats

),

final_dim_aircrafts as (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['aircraft_id_nk']) }} as aircraft_id_sk,
        aircraft_id_nk,
        aircraft_name,
        aircraft_iata,
        aircraft_icao,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    
    FROM
        dim_aircrafts
)

select * from final_dim_aircrafts