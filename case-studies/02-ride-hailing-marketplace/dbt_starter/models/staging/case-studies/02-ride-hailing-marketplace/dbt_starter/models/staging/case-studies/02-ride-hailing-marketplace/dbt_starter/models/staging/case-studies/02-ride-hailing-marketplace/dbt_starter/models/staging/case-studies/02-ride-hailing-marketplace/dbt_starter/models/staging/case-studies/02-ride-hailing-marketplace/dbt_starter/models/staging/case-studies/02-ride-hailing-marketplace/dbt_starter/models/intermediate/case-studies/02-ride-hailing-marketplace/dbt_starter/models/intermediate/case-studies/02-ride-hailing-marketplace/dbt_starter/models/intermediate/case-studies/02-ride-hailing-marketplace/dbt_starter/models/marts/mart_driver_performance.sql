{{ config(materialized='table', schema='marts') }}

-- Final driver performance table.
-- One row per driver.
-- Includes trips, earnings, completion rate, fraud rate.
-- Incentive earnings added from stg_driver_incentives.

with driver_base as (
    select * from {{ ref('int_drivers_with_trips') }}
),

incentives as (
    select
        driver_id,
        SUM(incentive_amount) as total_incentive_earnings
    from {{ ref('stg_driver_incentives') }}
    group by driver_id
),

final as (
    select
        d.driver_id,
        d.driver_city,
        d.driver_status,
        d.vehicle_type,
        d.total_trips,
        d.completed_trips,
        d.fraudulent_trips,
        d.gross_earnings,
        d.completion_rate_pct,
        coalesce(i.total_incentive_earnings, 0) as incentive_earnings,
        d.gross_earnings + coalesce(i.total_incentive_earnings, 0)
                                                as total_earnings
    from driver_base d
    left join incentives i on d.driver_id = i.driver_id
)

select * from final
