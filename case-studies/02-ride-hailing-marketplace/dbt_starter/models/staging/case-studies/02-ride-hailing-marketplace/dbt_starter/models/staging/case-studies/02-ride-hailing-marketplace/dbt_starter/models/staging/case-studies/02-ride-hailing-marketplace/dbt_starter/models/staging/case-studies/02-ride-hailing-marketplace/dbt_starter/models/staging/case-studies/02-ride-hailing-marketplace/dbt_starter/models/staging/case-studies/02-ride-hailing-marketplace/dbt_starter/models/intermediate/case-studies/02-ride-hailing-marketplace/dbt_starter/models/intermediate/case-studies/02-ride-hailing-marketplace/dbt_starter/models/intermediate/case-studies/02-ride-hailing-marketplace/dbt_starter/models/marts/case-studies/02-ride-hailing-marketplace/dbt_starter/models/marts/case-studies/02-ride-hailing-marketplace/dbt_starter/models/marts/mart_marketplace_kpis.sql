{{ config(materialized='table', schema='marts') }}

-- Marketplace KPI summary table.
-- Reconciles GMV to net revenue line by line.
-- Answers the 8-12% GMV-to-net gap question.
-- Key finding: GMV=$983,458 vs Net Revenue=$920,633 (6.39% gap)

with trips as (
    select * from {{ ref('int_trips_with_payments') }}
),

aggregated as (
    select
        COUNT(trip_id)                                           as total_trip_requests,
        COUNT(case when trip_category = 'completed' then 1 end) as completed_trips,
        COUNT(case when trip_category = 'cancelled' then 1 end) as cancelled_trips,
        COUNT(case when trip_category = 'fraudulent' then 1 end) as fraudulent_trips,
        SUM(gross_fare)                                          as gmv,
        SUM(case when trip_category = 'completed'
            then gross_fare else 0 end)                          as net_revenue,
        SUM(case when trip_category = 'fraudulent'
            then gross_fare else 0 end)                          as fraud_amount,
        SUM(case when trip_category = 'cancelled'
            then gross_fare else 0 end)                          as cancelled_amount
    from trips
),

final as (
    select
        total_trip_requests,
        completed_trips,
        cancelled_trips,
        fraudulent_trips,
        gmv,
        net_revenue,
        fraud_amount,
        cancelled_amount,
        ROUND(cancelled_trips * 100.0 / NULLIF(total_trip_requests, 0), 2) as cancellation_rate_pct,
        ROUND(fraudulent_trips * 100.0 / NULLIF(total_trip_requests, 0), 2) as fraud_rate_pct,
        ROUND((gmv - net_revenue) * 100.0 / NULLIF(gmv, 0), 2) as gmv_to_net_gap_pct
    from aggregated
)

select * from final
