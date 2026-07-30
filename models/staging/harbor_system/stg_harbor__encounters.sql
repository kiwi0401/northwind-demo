-- Encounter grain (one row per deduped visit). Reads stg_harbor__blob_latest so resubmissions
-- are already collapsed to the winning version. Timestamps are ISO-8601 with trailing 'Z'.
with src as (
    select blob from {{ ref('stg_harbor__blob_latest') }}
)
select
    {{ j('blob', '$.visit.visit_id') }}                                                     as encounter_id,
    'harbor_system'                                                                         as client_id,
    {{ j('blob', '$.visit.mrn_ref') }}                                                      as patient_ref,
    {{ j('blob', '$.visit.location_id') }}                                                  as facility_id,
    {{ j('blob', '$.visit.visit_class') }}                                                  as encounter_type,
    {{ ts_iso(j('blob', '$.visit.admission_datetime')) }}  as admit_ts,
    {{ ts_iso(j('blob', '$.visit.discharge_datetime')) }}  as discharge_ts,
    {{ j('blob', '$.schema_version') }}                                                     as schema_version
from src
