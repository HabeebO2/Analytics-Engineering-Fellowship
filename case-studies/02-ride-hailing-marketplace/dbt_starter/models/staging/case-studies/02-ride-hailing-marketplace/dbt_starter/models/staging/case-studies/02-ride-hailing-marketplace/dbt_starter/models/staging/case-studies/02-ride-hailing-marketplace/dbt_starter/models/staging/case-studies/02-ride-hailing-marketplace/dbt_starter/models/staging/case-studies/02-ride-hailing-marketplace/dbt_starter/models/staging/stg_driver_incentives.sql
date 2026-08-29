-- Cleans RAW_DRIVER_INCENTIVES.
-- One row per incentive line per driver per trip.
-- A single trip can appear on multiple campaign lines legitimately.
-- Deduplication only within same incentive_type + trip_id combination.

with source as (
    select * from {{ source('raw', 'raw_driver_incentives') }}
),

cleaned as (
    select
        incentive_id,
        driver_id,
        trip_id,
        incentive_type,
        incentive_amount,
        currency,
        paid_at as paid_at_raw
    from source
    where incentive_id is not null
    qualify row_number() over (
        partition by driver_id, trip_id, incentive_type
        order by paid_at desc
    ) = 1
)

select * from cleaned
