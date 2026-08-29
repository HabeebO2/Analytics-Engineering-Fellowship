{{ config(materialized='view') }}

-- Joins orders+payments+refunds with shipping data.
-- LEFT JOIN retains orders with no shipment record.
-- One row per order.

with orders_refunds as (
    select * from {{ ref('int_orders_with_refunds') }}
),

shipping as (
    select * from {{ ref('stg_shipping') }}
),

joined as (
    select
        o.*,
        s.shipment_id,
        s.carrier,
        s.shipping_cost,
        s.status         as shipping_status,
        s.shipped_at,
        s.delivered_at
    from orders_refunds o
    left join shipping s
        on o.order_id = s.order_id
)

select * from joined
