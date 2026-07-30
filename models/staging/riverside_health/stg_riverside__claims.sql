-- Claim grain (one row per encounter's claim). Single schema_version 1.0: only total_charge
-- (no v2.0 charge_amount field). Money is integer cents -> /100.
-- payer_id is a client-local code (P01/P02/.../P99), not canonical. Kept raw as sent;
-- the org-layer payer_xref seed maps P0x -> canonical, so don't map it here.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'riverside_health'
)
select
    {{ j('blob', '$.claim.claim_id') }}            as claim_id,
    {{ j('blob', '$.encounter.encounter_id') }}   as encounter_id,
    'riverside_health'                            as client_id,
    {{ j('blob', '$.claim.format') }}             as claim_format,
    {{ j('blob', '$.claim.payer_id') }}           as payer_id,  -- raw local code (P0x); mapped to canonical in the org layer
    {{ jnum('blob', '$.claim.total_charge', is_cents=true) }} as total_charge_usd,
    {{ j('blob', '$.schema_version') }}           as schema_version
from src
