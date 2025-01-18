with stg_dim_airports as (
    SELECT
        airport_id as airport_id_nk,
        airport_name,
        city,
        latitude,
        longitude
    
    FROM
        {{ source("dwh","airports") }}
),

dim_airports as (
    SELECT *
    FROM stg_dim_airports

),

final_dim_airports as (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['airport_id_nk']) }} as airport_id_sk,
        airport_id_nk,
        airport_name,
        city,
        latitude,
        longitude,
        {{ dbt_date.now() }} as created_at,
        {{ dbt_date.now() }} as updated_at
    
    from
        dim_airports
)

select * from final_dim_airports