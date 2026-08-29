{{ config(materialized='table') }}

-- Final revenue table. One row per order.
-- Single source of truth for revenue reporting.
-- Reconciles Finance vs Ops revenue definitions.
-- Recommended metric: net_revenue.

with base as (
    select * from {{ ref('int_orders_with_shipping') }}
),

final as (
    select
        order_id,
        customer_id,
        order_status,
        payment_status,
        order_amount,
        payment_amount,
        coalesce(refund_amount, 0)          as refund_amount,
        refund_reason,
        shipping_status,
        carrier,
        shipping_cost,
        shipped_at,
        delivered_at,

        -- Finance definition: revenue = payment received
        case
            when payment_status = 'succeeded'
            then payment_amount
            else 0
        end                                 as finance_revenue,

        -- Ops definition: revenue = order completed
        case
            when order_status = 'completed'
            then order_amount
            else 0
        end                                 as ops_revenue,

        -- Recommended: Finance minus refunds
        case
            when payment_status = 'succeeded'
            then payment_amount - coalesce(refund_amount, 0)
            else 0
        end                                 as net_revenue,

        order_created_at,
        payment_processed_at
    from base
)

select * from final
