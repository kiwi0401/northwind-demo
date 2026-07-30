-- Encounter grain. riverside_health = dialect A (flat), timestamps ISO-8601 with 'Z'.
-- Single schema_version 1.0 -- no version branch or field renames here.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'riverside_health'
)
select
    {{ j('blob', '$.encounter.encounter_id') }}                        as encounter_id,
    'riverside_health'                                                 as client_id,
    {{ j('blob', '$.encounter.patient_ref') }}                         as patient_ref,
    {{ j('blob', '$.encounter.facility_id') }}                         as facility_id,
    {{ j('blob', '$.encounter.encounter_type') }}                      as encounter_type,
    {{ ts_iso(j('blob', '$.encounter.admit_ts')) }}      as admit_ts,
    {{ ts_iso(j('blob', '$.encounter.discharge_ts')) }}  as discharge_ts,
    {{ j('blob', '$.schema_version') }}                                as schema_version
from src
