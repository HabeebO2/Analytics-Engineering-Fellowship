{{ config(materialized='view') }}

-- Joins orders+payments with refund records.
-- LEFT JOIN retains orders with no refund.
-- One row per order.

with orders_payments as (
    select * from {{ ref('int_orders_with_payments') }}
),

refunds as (
    select * from {{ ref('stg_refunds') }}
),

joined as (
    select
        op.*,
        r.refund_id,
        r.refund_amount,
        r.refund_reason,
        r.refund_status
    from orders_payments op
    left join refunds r
        on op.order_id = r.order_id
)

select * from joined
