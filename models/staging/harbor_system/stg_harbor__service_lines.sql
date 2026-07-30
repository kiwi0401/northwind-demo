-- Service-line grain (fan-out: many lines per claim) under billing.claim.lines[].
-- Fields: seq, hcpcs, qty, amount. Money already in USD dollars (no cents conversion).
-- Reads the deduped blob so a resubmitted visit's lines are counted once.
with src as (
    select blob from {{ ref('stg_harbor__blob_latest') }}
)
select
    {{ j('blob', '$.billing.claim.claim_no') }}   as claim_id,
    {{ j('blob', '$.visit.visit_id') }}           as encounter_id,
    ({{ j('line', '$.seq') }})::int               as line_no,
    {{ j('line', '$.hcpcs') }}                    as procedure_code,
    ({{ j('line', '$.qty') }})::int               as units,
    {{ jnum('line', '$.amount') }}                as charge_usd
from src, {{ explode('blob', '$.billing.claim.lines') }} as t(line)
