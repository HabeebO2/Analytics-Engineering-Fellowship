-- Cleans RAW_DRIVERS.
-- DRIVER_ID reused when driver re-onboards.
-- Keep most recent record per driver_id.
-- Decision: latest onboarding = current driver state.

with source as (
    select * from {{ source('raw', 'raw_drivers') }}
),

cleaned as (
    select
        driver_id       as driver_id,
        home_city       as driver_city,
        vehicle_class   as vehicle_type,
        driver_status   as driver_status,
        onboarded_at    as onboarded_at_raw
    from source
    where driver_id is not null
    qualify row_number() over (
        partition by driver_id
        order by onboarded_at desc
    ) = 1
)

select * from cleaned
