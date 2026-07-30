-- Authorization grain (one per encounter). The $.authorization block is absent
-- ~40% of the time; absence means "not required" here (a valid state, not missing data).
-- When the block is null -> auth_status = 'not_required', has_authorization = false.
-- When present -> use its status and has_authorization = true.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'plains_regional'
)
select
    {{ j('blob', '$.encounter.encounter_id') }}                    as encounter_id,
    {{ j('blob', '$.authorization.auth_id') }}                    as auth_id,
    case
        when (blob #> '{authorization}') is null then 'not_required'
        else {{ j('blob', '$.authorization.status') }}
    end                                                           as auth_status,
    (blob #> '{authorization}') is not null                       as has_authorization
from src
