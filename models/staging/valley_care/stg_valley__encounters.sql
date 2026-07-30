-- Encounter grain. valley_care = dialect C (events[] array); pivot by kind='encounter'.
-- Exactly one encounter event per case. Timestamps are ISO-8601 with trailing 'Z' (strip before cast).
-- This dialect sends NO patient id -> patient_ref is null. case_id is carried as the cross-model
-- linking key (charges/payments reference case_id, not encounter_id).
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'valley_care'
),
enc as (
    select
        {{ j('blob', '$.case_id') }}        as case_id,
        {{ j('blob', '$.schema_version') }} as schema_version,
        ev
    from src, {{ explode('blob', '$.events') }} as t(ev)
    where {{ j('ev', '$.kind') }} = 'encounter'
)
select
    {{ j('ev', '$.id') }}                                            as encounter_id,
    case_id,
    'valley_care'                                                   as client_id,
    cast(null as varchar)                                           as patient_ref,
    {{ j('ev', '$.facility') }}                                     as facility_id,
    {{ j('ev', '$.type') }}                                         as encounter_type,
    {{ ts_iso(j('ev', '$.start')) }}                               as admit_ts,
    {{ ts_iso(j('ev', '$.end')) }}                                 as discharge_ts,
    schema_version
from enc
