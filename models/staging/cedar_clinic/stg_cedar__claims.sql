-- Claim grain (one row per claim_id). Dialect C has no claim object: a claim is only
-- implied by the claim_id on its charge/payment events. Roll charge events up to the claim
-- to get total_charge_usd. Dialect C sends no claim format and no payer -> null (per contract).
with charges as (
    select
        {{ j('blob', '$.case_id') }}          as case_id,
        {{ j('blob', '$.schema_version') }}   as schema_version,
        {{ j('ev', '$.claim_id') }}           as claim_id,
        {{ jnum('ev', '$.amount') }}          as amount
    from {{ source('raw', 'client_blob') }},
         {{ explode('blob', '$.events') }} as t(ev)
    where source_client = 'cedar_clinic'
      and {{ j('ev', '$.kind') }} = 'charge'
)
select
    claim_id,
    max(case_id)          as case_id,
    'cedar_clinic'        as client_id,
    cast(null as varchar) as claim_format,   -- dialect C sends no claim format
    cast(null as varchar) as payer_id,       -- dialect C sends no payer
    sum(amount)           as total_charge_usd,
    max(schema_version)   as schema_version
from charges
group by claim_id
