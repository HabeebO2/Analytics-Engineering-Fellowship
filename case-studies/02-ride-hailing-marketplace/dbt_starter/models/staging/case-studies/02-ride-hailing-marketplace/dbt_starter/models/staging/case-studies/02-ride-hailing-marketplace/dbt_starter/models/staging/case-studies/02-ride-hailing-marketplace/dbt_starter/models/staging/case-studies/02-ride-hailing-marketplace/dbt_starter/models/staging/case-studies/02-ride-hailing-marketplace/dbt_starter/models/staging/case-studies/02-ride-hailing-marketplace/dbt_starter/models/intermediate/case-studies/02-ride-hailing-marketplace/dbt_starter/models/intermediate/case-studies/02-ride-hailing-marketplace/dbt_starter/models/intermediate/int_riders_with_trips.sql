{{ config(materialized='view', schema='intermediate') }}

-- Joins riders to their trip history.
-- Multiple active rider definitions for each stakeholder team.
-- Decision: 30-day trailing window as primary active definition.

with riders as (
    select * from {{ ref('stg_riders') }}
),

trips as (
    select * from {{ ref('stg_trips') }}
),

rider_trip_summary as (
    select
        r.rider_id,
        r.home_city,
        r.account_status,
        COUNT(t.trip_id)                                        as total_trips_ever,
        COUNT(case
            when t.trip_category = 'completed'
            and t.requested_at_raw >= dateadd(day, -30, current_date())
            then 1 end)                                         as trips_completed_30d,
        COUNT(case
            when t.trip_category = 'completed'
            and t.requested_at_raw >= dateadd(day, -90, current_date())
            then 1 end)                                         as trips_completed_90d,
        case when COUNT(case
            when t.trip_category = 'completed'
            and t.requested_at_raw >= dateadd(day, -30, current_date())
            then 1 end) > 0
        then true else false end                                as is_active_30d,
        case when COUNT(case
            when t.trip_category = 'completed'
            and t.requested_at_raw >= dateadd(day, -90, current_date())
            then 1 end) > 0
        then true else false end                                as is_active_90d,
        case when r.account_status = 'active'
        then true else false end                                as is_active_crm
    from riders r
    left join trips t on r.rider_id = t.rider_id
    group by 1, 2, 3
)

select * from rider_trip_summary
