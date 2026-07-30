-- Encounter grain (one row per case). cedar_clinic = dialect C (events[] array):
-- pivot by kind, keep only the kind='encounter' event. One encounter per case_id.
-- Timestamps are epoch millis on start/end -> to_timestamp(ms/1000). No DRG for this client.
select
    {{ j('ev', '$.id') }}                                                 as encounter_id,
    {{ j('blob', '$.case_id') }}                                          as case_id,
    'cedar_clinic'                                                        as client_id,
    cast(null as varchar)                                                 as patient_ref,  -- dialect C sends no patient id
    {{ j('ev', '$.facility') }}                                           as facility_id,
    {{ j('ev', '$.type') }}                                               as encounter_type,
    {{ ts_epoch_ms(j('ev', '$.start')) }}                                 as admit_ts,
    {{ ts_epoch_ms(j('ev', '$.end')) }}                                   as discharge_ts,
    {{ j('blob', '$.schema_version') }}                                   as schema_version
from {{ source('raw', 'client_blob') }},
     {{ explode('blob', '$.events') }} as t(ev)
where source_client = 'cedar_clinic'
  and {{ j('ev', '$.kind') }} = 'encounter'
