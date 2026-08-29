-- Cleans RAW_RIDERS.
-- One row per rider. Corrupted signup_at retained but not used.
-- account_status has three values: active, dormant, guest — all kept.
-- Activity measured in mart_rider_activity, not here.

with source as (
    select * from {{ source('raw', 'raw_riders') }}
),

cleaned as (
    select
        RIDER_ID        as rider_id,
        HOME_CITY       as home_city,
        ACCOUNT_STATUS  as account_status,
        REFERRED_BY     as referred_by_rider_id,
        SIGNUP_AT       as signup_at_raw
    from source
    where rider_id is not null
)

select * from cleaned
