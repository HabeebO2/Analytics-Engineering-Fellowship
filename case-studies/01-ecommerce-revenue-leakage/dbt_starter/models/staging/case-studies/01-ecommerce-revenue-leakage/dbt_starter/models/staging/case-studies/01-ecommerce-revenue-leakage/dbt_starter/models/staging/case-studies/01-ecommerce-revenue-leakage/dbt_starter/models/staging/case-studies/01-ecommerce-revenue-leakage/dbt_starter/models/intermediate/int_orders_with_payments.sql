{{ config(materialized='view') }}

-- Joins cleaned orders to their payment records.
-- LEFT JOIN retains orders with no payment (cancelled, failed).
-- One row per order.

with orders as (
    select * from {{ ref('stg_orders') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

joined as (
    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_amount,
        o.currency,
        o.created_at                as order_created_at,
        p.payment_id,
        p.payment_status,
        p.amount                    as payment_amount,
        p.payment_method,
        p.gateway_fee,
        p.processed_at              as payment_processed_at
    from orders o
    left join payments p
        on o.order_id = p.order_id
)

select * from joined
