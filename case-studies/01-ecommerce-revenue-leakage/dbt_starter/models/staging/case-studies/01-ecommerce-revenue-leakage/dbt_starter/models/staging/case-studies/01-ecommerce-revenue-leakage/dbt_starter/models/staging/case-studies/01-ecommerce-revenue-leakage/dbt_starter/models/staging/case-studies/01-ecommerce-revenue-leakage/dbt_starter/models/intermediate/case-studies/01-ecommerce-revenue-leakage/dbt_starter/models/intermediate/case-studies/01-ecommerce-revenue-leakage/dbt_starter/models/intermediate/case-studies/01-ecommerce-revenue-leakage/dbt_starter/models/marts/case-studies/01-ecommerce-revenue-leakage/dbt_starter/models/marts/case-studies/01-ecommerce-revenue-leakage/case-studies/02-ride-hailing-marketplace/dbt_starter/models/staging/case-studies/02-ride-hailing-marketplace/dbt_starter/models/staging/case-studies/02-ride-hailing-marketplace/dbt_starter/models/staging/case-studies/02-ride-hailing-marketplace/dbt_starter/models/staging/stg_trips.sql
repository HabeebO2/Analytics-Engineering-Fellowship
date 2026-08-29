-- Cleans RAW_TRIPS.
-- One row per trip request.
-- Classifies each trip as completed, cancelled, or fraudulent.
-- GROSS_FARE kept as GMV input.
-- is_fraud_flagged arrives AFTER the trip.
-- Decision: fraudulent trips take priority in classification.

with source as (
    select * from {{ source('raw', 'raw_trips') }}
),

cleaned as (
    select
        trip_id,
        rider_id,
        driver_id,
        trip_status,
        gross_fare,
        currency,
        is_fraud_flagged,
        requested_at as requested_at_raw,

        case
            when is_fraud_flagged = true   then 'fraudulent'
            when trip_status = 'completed' then 'completed'
            when trip_status = 'cancelled' then 'cancelled'
            else 'unknown'
        end as trip_category

    from source
    where trip_id is not null
)

select * from cleaned
