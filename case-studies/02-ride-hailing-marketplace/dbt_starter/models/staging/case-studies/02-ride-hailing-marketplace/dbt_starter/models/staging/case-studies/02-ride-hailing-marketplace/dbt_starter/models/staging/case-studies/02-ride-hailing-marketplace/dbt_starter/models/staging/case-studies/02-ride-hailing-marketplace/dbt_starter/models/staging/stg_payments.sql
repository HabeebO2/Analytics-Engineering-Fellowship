-- Cleans RAW_PAYMENTS.
-- One row per SUCCESSFUL payment per trip.
-- Deduplicates retried and double-logged captures.
-- Decision: keep only captured status payments.
-- Decision: keep latest captured payment per trip.

with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

cleaned as (
    select
        payment_id,
        trip_id,
        payment_status,
        amount,
        currency,
        captured_at as captured_at_raw
    from source
    where payment_id is not null
    and payment_status = 'captured'
    qualify row_number() over (
        partition by trip_id
        order by captured_at desc
    ) = 1
)

select * from cleaned
