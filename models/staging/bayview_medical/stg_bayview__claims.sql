-- Claim grain (one row per encounter's claim). Claim key = billing.claim.claim_no.
-- claim_format = bill_type; payer_id kept raw; charges already in USD dollars.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'bayview_medical'
)
select
    {{ j('blob', '$.billing.claim.claim_no') }}   as claim_id,
    {{ j('blob', '$.visit.visit_id') }}           as encounter_id,
    'bayview_medical'                             as client_id,
    {{ j('blob', '$.billing.claim.bill_type') }}  as claim_format,
    {{ j('blob', '$.billing.claim.payer') }}      as payer_id,
    {{ jnum('blob', '$.billing.claim.charges') }} as total_charge_usd,
    {{ j('blob', '$.schema_version') }}           as schema_version
from src
