-- Service-line grain (fan-out driver: 1..12 lines per claim). Money in integer cents.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'northstar_health'
)
select
    {{ j('blob', '$.claim.claim_id') }}          as claim_id,
    {{ j('blob', '$.encounter.encounter_id') }}  as encounter_id,
    ({{ j('line', '$.line') }})::int             as line_no,
    {{ j('line', '$.hcpcs') }}                   as procedure_code,
    ({{ j('line', '$.units') }})::int            as units,
    {{ jnum('line', '$.charge', is_cents=true) }} as charge_usd
from src, {{ explode('blob', '$.claim.service_lines') }} as t(line)
