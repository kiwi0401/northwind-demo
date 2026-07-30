-- Authorization grain. Present on most encounters. An absent auth block here means it
-- was not sent (not the "not required" semantics that plains_regional uses).
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'riverside_health'
)
select
    {{ j('blob', '$.encounter.encounter_id') }}                    as encounter_id,
    {{ j('blob', '$.authorization.auth_id') }}                    as auth_id,
    {{ j('blob', '$.authorization.status') }}                     as auth_status,
    (blob #> '{authorization}') is not null                       as has_authorization
from src
