-- Encounter grain. metro_childrens = dialect B (visit-nested). Timestamps are
-- date-only ('YYYY-MM-DD', no time, no 'Z'). ts_iso strips a trailing 'Z' (there is none
-- to strip) and casts the date-only string directly to a midnight timestamp.
-- Encounter key = visit.visit_id; patient = visit.mrn_ref; facility = visit.location_id.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'metro_childrens'
)
select
    {{ j('blob', '$.visit.visit_id') }}                                  as encounter_id,
    'metro_childrens'                                                    as client_id,
    {{ j('blob', '$.visit.mrn_ref') }}                                   as patient_ref,
    {{ j('blob', '$.visit.location_id') }}                               as facility_id,
    {{ j('blob', '$.visit.visit_class') }}                               as encounter_type,
    {{ ts_iso(j('blob', '$.visit.admission_datetime')) }} as admit_ts,
    {{ ts_iso(j('blob', '$.visit.discharge_datetime')) }} as discharge_ts,
    {{ j('blob', '$.schema_version') }}                                  as schema_version
from src
