-- Remittance grain (one 835 per claim). paid = payments[].amt (USD dollars). Denial is derived
-- from stg_summit__adjustments: is_denied when any CARC on the claim is a true denial code;
-- denial_reason = that grp-rsn (e.g. 'CO-50'). Routine adjustments are ignored for the flag.
with payments as (
    select
        {{ j('blob', '$.account.acct_id') }}  as encounter_id,
        {{ j('pay', '$.claim') }}             as claim_id,
        {{ jnum('pay', '$.amt') }}            as paid_amount_usd
    from {{ source('raw', 'client_blob') }}, {{ explode('blob', '$.payments') }} as t(pay)
    where source_client = 'summit_ortho'
),
denials as (
    select
        claim_id,
        bool_or(is_denial_code)                                            as is_denied,
        max(case when is_denial_code then carc_code end)                   as denial_reason
    from {{ ref('stg_summit__adjustments') }}
    group by 1
)
select
    p.claim_id,
    p.encounter_id,
    p.paid_amount_usd,
    coalesce(d.is_denied, false)   as is_denied,
    d.denial_reason
from payments p
left join denials d on p.claim_id = d.claim_id
