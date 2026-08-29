{{ config(materialized='view', schema='intermediate') }}

-- Joins drivers to their trip history.
-- One row per driver.
-- Calculates total trips, completion rate, fraud rate, gross earnings.

with drivers as (
    select * from {{ ref('stg_drivers') }}
),

trips as (
    select * from {{ ref('stg_trips') }}
),

driver_trip_summary as (
    select
        d.driver_id,
        d.driver_city,
        d.driver_status,
        d.vehicle_type,
        COUNT(t.trip_id)                                        as total_trips,
        COUNT(case when t.trip_category = 'completed'
              then 1 end)                                       as completed_trips,
        COUNT(case when t.trip_category = 'fraudulent'
              then 1 end)                                       as fraudulent_trips,
        SUM(case when t.trip_category = 'completed'
            then t.gross_fare else 0 end)                       as gross_earnings,
        ROUND(
            COUNT(case when t.trip_category = 'completed'
                  then 1 end) * 100.0
            / NULLIF(COUNT(t.trip_id), 0), 2
        )                                                       as completion_rate_pct
    from drivers d
    left join trips t on d.driver_id = t.driver_id
    group by 1, 2, 3, 4
)

select * from driver_trip_summary
