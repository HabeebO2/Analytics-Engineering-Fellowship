-- Cleans RAW_SHIPPING.
-- One row per shipment.
-- Finding: NULL delivered_at means order is in transit - valid, not an error.
-- Decision: retain all records, use status column instead of timestamp.

with source as (
    select * from {{ source('raw', 'raw_shipping') }}
),

cleaned as (
    select
        shipment_id,
        order_id,
        carrier,
        shipping_cost,
        status,
        shipped_at,
        delivered_at
    from source
    where shipment_id is not null
)

select * from cleaned
