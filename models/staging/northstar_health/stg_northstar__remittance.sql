-- Remittance grain (one 835 per claim). Denial encoded as a denial_codes[] array.
-- is_denied = at least one denial code present. Money in integer cents.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'northstar_health'
)
select
    {{ j('blob', '$.claim.claim_id') }}                                as claim_id,
    {{ j('blob', '$.encounter.encounter_id') }}                       as encounter_id,
    {{ jnum('blob', '$.remittance.paid_amount', is_cents=true) }}      as paid_amount_usd,
    coalesce({{ jarr_len('blob', '$.remittance.denial_codes') }}, 0) > 0  as is_denied,
    {{ j('blob', '$.remittance.denial_codes[0]') }}                   as denial_reason
from src
