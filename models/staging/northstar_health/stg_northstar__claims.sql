-- Claim grain (one row per encounter's claim). schema_version 2.0 renamed
-- total_charge -> charge_amount; coalesce both for back-compat. Money is integer cents -> /100.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'northstar_health'
)
select
    {{ j('blob', '$.claim.claim_id') }}            as claim_id,
    {{ j('blob', '$.encounter.encounter_id') }}   as encounter_id,
    'northstar_health'                            as client_id,
    {{ j('blob', '$.claim.format') }}             as claim_format,
    {{ j('blob', '$.claim.payer_id') }}           as payer_id,
    coalesce(
        {{ jnum('blob', '$.claim.total_charge', is_cents=true) }},
        {{ jnum('blob', '$.claim.charge_amount', is_cents=true) }}
    )                                             as total_charge_usd,
    {{ j('blob', '$.claim.billing_provider') }}   as billing_provider_npi,  -- only present in v2.0
    {{ j('blob', '$.schema_version') }}           as schema_version
from src
