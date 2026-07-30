-- Authorization grain. Present on most encounters. Absent auth here means the block
-- was simply not sent (not the "not required" semantics some other feeds use).
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'northstar_health'
)
select
    {{ j('blob', '$.encounter.encounter_id') }}                    as encounter_id,
    {{ j('blob', '$.authorization.auth_id') }}                    as auth_id,
    {{ j('blob', '$.authorization.status') }}                     as auth_status,
    (blob #> '{authorization}') is not null                       as has_authorization
from src
