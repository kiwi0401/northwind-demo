-- Service-line grain; 1..N lines per claim.
-- Money is a comma-formatted string in dollars -> jnum strips commas, no is_cents.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'plains_regional'
)
select
    {{ j('blob', '$.claim.claim_id') }}          as claim_id,
    {{ j('blob', '$.encounter.encounter_id') }}  as encounter_id,
    ({{ j('line', '$.line') }})::int             as line_no,
    {{ j('line', '$.hcpcs') }}                   as procedure_code,
    ({{ j('line', '$.units') }})::int            as units,
    {{ jnum('line', '$.charge') }}               as charge_usd
from src, {{ explode('blob', '$.claim.service_lines') }} as t(line)
