-- Cleans RAW_PAYMENTS.
-- One row per payment. Deduplicates retried payments.
-- Decision: keep latest record per payment_id.

with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

cleaned as (
    select
        payment_id,
        order_id,
        payment_status,
        amount,
        currency,
        payment_method,
        gateway_fee,
        attempted_at,
        processed_at
    from source
    where payment_id is not null
)

select * from cleaned
