-- Claim grain (one row per deduped visit's claim). Claim key = billing.claim.claim_no.
-- claim_format = bill_type. Money already in USD dollars. Reads the deduped blob so the
-- superseded original claim is dropped and totals are not double-counted.
with src as (
    select blob from {{ ref('stg_harbor__blob_latest') }}
)
select
    {{ j('blob', '$.billing.claim.claim_no') }}   as claim_id,
    {{ j('blob', '$.visit.visit_id') }}           as encounter_id,
    'harbor_system'                               as client_id,
    {{ j('blob', '$.billing.claim.bill_type') }}  as claim_format,
    {{ j('blob', '$.billing.claim.payer') }}      as payer_id,
    {{ jnum('blob', '$.billing.claim.charges') }} as total_charge_usd,
    {{ j('blob', '$.schema_version') }}           as schema_version
from src
