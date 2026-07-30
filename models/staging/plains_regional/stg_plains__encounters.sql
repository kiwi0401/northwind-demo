-- Encounter grain. plains_regional = dialect A (flat). Single schema_version 1.0.
-- Timestamps are naive (e.g. '2025-03-01T14:05:00', no trailing 'Z') -> cast directly.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'plains_regional'
)
select
    {{ j('blob', '$.encounter.encounter_id') }}                as encounter_id,
    'plains_regional'                                          as client_id,
    {{ j('blob', '$.encounter.patient_ref') }}                as patient_ref,
    {{ j('blob', '$.encounter.facility_id') }}                as facility_id,
    {{ j('blob', '$.encounter.encounter_type') }}             as encounter_type,
    {{ ts_iso(j('blob', '$.encounter.admit_ts')) }}      as admit_ts,
    {{ ts_iso(j('blob', '$.encounter.discharge_ts')) }}  as discharge_ts,
    {{ j('blob', '$.schema_version') }}                       as schema_version
from src
