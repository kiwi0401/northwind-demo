-- Encounter grain. summit_ortho = dialect D (EMR export). Encounter key = account.acct_id.
-- facility_id is top-level (not under account); encounter_type = account.type.
-- Timestamps are ISO-8601 with trailing 'Z' (strip before cast, like northstar).
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'summit_ortho'
)
select
    {{ j('blob', '$.account.acct_id') }}                                            as encounter_id,
    'summit_ortho'                                                                  as client_id,
    {{ j('blob', '$.patient.ref') }}                                                as patient_ref,
    {{ j('blob', '$.facility_id') }}                                                as facility_id,
    {{ j('blob', '$.account.type') }}                                              as encounter_type,
    {{ ts_iso(j('blob', '$.account.adm')) }}                                        as admit_ts,
    {{ ts_iso(j('blob', '$.account.dis')) }}                                        as discharge_ts,
    {{ j('blob', '$.schema_version') }}                                            as schema_version
from src
