-- Authorization grain (one per encounter). bayview sends an auth{auth_id, status} block.
-- Absent block = not sent (not the "not required" semantics); has_authorization tracks presence.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'bayview_medical'
)
select
    {{ j('blob', '$.visit.visit_id') }}              as encounter_id,
    {{ j('blob', '$.auth.auth_id') }}                as auth_id,
    {{ j('blob', '$.auth.status') }}                 as auth_status,
    (blob #> '{auth}') is not null                   as has_authorization
from src
