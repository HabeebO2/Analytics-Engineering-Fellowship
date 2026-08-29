-- Cleans RAW_REFUNDS.
-- One row per refund. Deduplicates duplicate refund IDs.
-- Decision: keep latest record per refund_id ordered by requested_at.
-- Finding: some refund_id values are NULL - excluded entirely.
-- Tradeoff: may slightly undercount total refunds.

with source as (
    select * from {{ source('raw', 'raw_refunds') }}
),

cleaned as (
    select
        refund_id,
        order_id,
        payment_id,
        refund_amount,
        currency,
        refund_reason,
        refund_status,
        requested_at,
        processed_at
    from source
    where refund_id is not null
    qualify row_number() over (
        partition by refund_id
        order by requested_at desc
    ) = 1
)

select * from cleaned
