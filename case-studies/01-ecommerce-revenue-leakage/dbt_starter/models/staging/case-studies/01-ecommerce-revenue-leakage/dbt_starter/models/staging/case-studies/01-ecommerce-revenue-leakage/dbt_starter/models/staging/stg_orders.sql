-- Cleans RAW_ORDERS.
-- One row per order. Deduplicates by keeping latest updated_at.
-- Decision: keep most recent record per order_id.

with source as (
    select * from {{ source('raw', 'raw_orders') }}
),

cleaned as (
    select
        order_id,
        customer_id,
        order_status,
        order_amount,
        currency,
        created_at,
        updated_at
    from source
    where order_id is not null
    qualify row_number() over (
        partition by order_id
        order by updated_at desc
    ) = 1
)

select * from cleaned
