-- Claim grain (one row per encounter's claim). Single schema_version 1.0, no field rename,
-- so read $.claim.total_charge directly (no coalesce with charge_amount). Money is a
-- comma-formatted string like "1,250.00" in dollars -> jnum strips commas, no is_cents.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'plains_regional'
)
select
    {{ j('blob', '$.claim.claim_id') }}            as claim_id,
    {{ j('blob', '$.encounter.encounter_id') }}   as encounter_id,
    'plains_regional'                             as client_id,
    {{ j('blob', '$.claim.format') }}             as claim_format,
    {{ j('blob', '$.claim.payer_id') }}           as payer_id,
    {{ jnum('blob', '$.claim.total_charge') }}    as total_charge_usd,
    {{ j('blob', '$.schema_version') }}           as schema_version
from src
