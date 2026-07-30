-- Claim grain (one row per claim_id). Dialect C has NO claim header event, so a claim is
-- synthesized from its charge lines: total_charge_usd = sum of the charge amounts for that
-- claim_id. No claim_format and no payer_id are sent in this dialect (both null; org layer maps).
-- Money is USD DOLLARS.
with charges as (
    select
        {{ j('blob', '$.case_id') }}        as case_id,
        {{ j('ev', '$.claim_id') }}         as claim_id,
        {{ jnum('ev', '$.amount') }}        as amount,
        {{ j('blob', '$.schema_version') }} as schema_version
    from {{ source('raw', 'client_blob') }} src,
         {{ explode('blob', '$.events') }} as t(ev)
    where source_client = 'valley_care'
      and {{ j('ev', '$.kind') }} = 'charge'
)
select
    claim_id,
    case_id,
    'valley_care'          as client_id,
    cast(null as varchar)  as claim_format,
    cast(null as varchar)  as payer_id,
    sum(amount)            as total_charge_usd,
    max(schema_version)    as schema_version
from charges
group by claim_id, case_id
