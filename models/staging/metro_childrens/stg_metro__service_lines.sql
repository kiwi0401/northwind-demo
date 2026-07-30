-- Service-line grain (fan-out driver: many lines per claim). Lines under billing.claim.lines
-- with {seq, hcpcs, qty, amount}. Money is already in USD DOLLARS (no cents conversion).
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'metro_childrens'
)
select
    {{ j('blob', '$.billing.claim.claim_no') }}  as claim_id,
    {{ j('blob', '$.visit.visit_id') }}          as encounter_id,
    ({{ j('line', '$.seq') }})::int              as line_no,
    {{ j('line', '$.hcpcs') }}                   as procedure_code,
    ({{ j('line', '$.qty') }})::int              as units,
    {{ jnum('line', '$.amount') }}               as charge_usd
from src, {{ explode('blob', '$.billing.claim.lines') }} as t(line)
