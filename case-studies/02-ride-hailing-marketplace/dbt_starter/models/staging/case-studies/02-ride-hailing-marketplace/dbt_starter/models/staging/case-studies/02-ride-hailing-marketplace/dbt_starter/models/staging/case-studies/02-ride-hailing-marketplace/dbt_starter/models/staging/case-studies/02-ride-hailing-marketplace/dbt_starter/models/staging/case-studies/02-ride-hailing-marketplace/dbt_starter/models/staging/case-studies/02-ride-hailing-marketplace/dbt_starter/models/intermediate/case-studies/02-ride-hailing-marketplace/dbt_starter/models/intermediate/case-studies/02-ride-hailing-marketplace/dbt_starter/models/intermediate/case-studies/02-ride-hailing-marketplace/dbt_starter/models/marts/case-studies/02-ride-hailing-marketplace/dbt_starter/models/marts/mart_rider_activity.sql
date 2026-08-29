{{ config(materialized='table', schema='marts') }}

-- Final rider activity table.
-- One row per rider.
-- All active rider definitions shown so each team
-- can filter to their preferred metric.
-- Primary recommended metric: is_active_30d

with rider_base as (
    select * from {{ ref('int_riders_with_trips') }}
),

final as (
    select
        rider_id,
        home_city,
        account_status,
        total_trips_ever,
        trips_completed_30d,
        trips_completed_90d,
        is_active_30d,
        is_active_90d,
        is_active_crm,
        is_active_30d       as is_active_recommended
    from rider_base
)

select * from final
