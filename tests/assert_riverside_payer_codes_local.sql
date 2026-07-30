-- riverside payer_id must stay as the client-local code (P0x pattern), not canonicalized in the
-- client layer. Canonical payer names are alphabetic; a local code looks like 'P' + digits. Fails
-- (returns rows) if any payer_id was mapped to a non-local value, which would mean the client layer
-- resolved a code that the org payer_xref is meant to own.
select
    claim_id,
    payer_id
from {{ ref('int_riverside__claim_financials') }}
where payer_id is null
   or payer_id not similar to 'P[0-9]+'
