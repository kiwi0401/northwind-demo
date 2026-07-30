-- Encounter grain. bayview_medical = dialect B (visit-nested), timestamps ISO-8601 with 'Z'.
-- Encounter key = visit.visit_id; patient = visit.mrn_ref; facility = visit.location_id.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'bayview_medical'
)
select
    {{ j('blob', '$.visit.visit_id') }}                                                    as encounter_id,
    'bayview_medical'                                                                       as client_id,
    {{ j('blob', '$.visit.mrn_ref') }}                                                      as patient_ref,
    {{ j('blob', '$.visit.location_id') }}                                                  as facility_id,
    {{ j('blob', '$.visit.visit_class') }}                                                  as encounter_type,
    {{ ts_iso(j('blob', '$.visit.admission_datetime')) }}                                   as admit_ts,
    {{ ts_iso(j('blob', '$.visit.discharge_datetime')) }}                                   as discharge_ts,
    {{ j('blob', '$.schema_version') }}                                                     as schema_version
from src
