-- Claim grain. Claim key = payments[].claim. summit sends no payer and no claim format on the
-- wire, so both are null here (org layer tolerates null payer_id). claim_seq = 1-based array
-- position of the payment; the primary claim (seq=1) receives the encounter's charges downstream.
with payments as (
    select
        {{ j('cb.blob', '$.account.acct_id') }}                                                  as encounter_id,
        t.pay                                                                                    as pay,
        t.claim_seq                                                                              as claim_seq
    from {{ source('raw', 'client_blob') }} cb,
         {{ explode_ord('cb.blob', '$.payments') }} as t(pay, claim_seq)
    where cb.source_client = 'summit_ortho'
)
select
    {{ j('pay', '$.claim') }}      as claim_id,
    encounter_id,
    'summit_ortho'                 as client_id,
    cast(null as varchar)          as claim_format,
    cast(null as varchar)          as payer_id,
    claim_seq
from payments
