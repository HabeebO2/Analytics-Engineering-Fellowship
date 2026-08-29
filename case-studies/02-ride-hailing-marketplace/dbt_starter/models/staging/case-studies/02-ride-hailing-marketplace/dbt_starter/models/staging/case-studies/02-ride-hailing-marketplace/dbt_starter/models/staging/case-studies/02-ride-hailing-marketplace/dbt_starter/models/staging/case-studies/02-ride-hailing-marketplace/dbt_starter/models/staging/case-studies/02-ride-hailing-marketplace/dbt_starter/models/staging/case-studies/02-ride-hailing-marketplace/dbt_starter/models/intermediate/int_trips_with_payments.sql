{{ config(materialized='view', schema='intermediate') }}

-- Joins cleaned trips to their captured payment.
-- LEFT JOIN ensures cancelled/unpaid trips are retained.
-- One row per trip.

with trips as (
    select * from {{ ref('stg_trips') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

joined as (
    select
        t.trip_id,
        t.rider_id,
        t.driver_id,
        t.trip_status,
        t.trip_category,
        t.gross_fare,
        t.currency          as trip_currency,
        t.is_fraud_flagged,
        t.requested_at_raw,
        p.payment_id,
        p.payment_status,
        p.amount            as payment_amount,
        p.currency          as payment_currency,
        p.captured_at_raw
    from trips t
    left join payments p
        on t.trip_id = p.trip_id
)

select * from joined
