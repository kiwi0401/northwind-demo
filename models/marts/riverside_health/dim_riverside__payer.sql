-- Payer dimension. riverside sends client-local payer codes (P01, P02, P03,
-- P07, P09, P99) on claim.payer_id. These are not canonical payer names and are not present in
-- seed_payers; they are left raw here and the org-layer payer_xref seed maps
-- P0x -> canonical. Surfaces the local codes with usage counts.
with claims as (
    select payer_id from {{ ref('int_riverside__claim_financials') }}
)
select
    payer_id                                    as local_payer_code,
    'riverside_health'                          as client_id,
    count(*)                                    as claim_count,
    false                                       as is_canonical,  -- must be resolved via org payer_xref
    'unmapped local code; resolve via org payer_xref seed' as mapping_note
from claims
group by 1
order by claim_count desc
