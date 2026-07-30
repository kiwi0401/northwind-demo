-- Remittance grain (one row per claim). Denial encoded in billing.remit.carc[] as {grp, code, amt}.
-- Denial rule: is_denied when a carc entry has grp='CO' and code in (50,16,11,197).
-- All other carc entries are routine contractual/patient adjustments, not denials.
-- The carc array is aggregated to claim grain in a CTE so this model stays one row per claim.
with base as (
    select
        blob,
        {{ j('blob', '$.billing.claim.claim_no') }}  as claim_id,
        {{ j('blob', '$.visit.visit_id') }}          as encounter_id
    from {{ ref('stg_harbor__blob_latest') }}
),
carc as (
    select
        base.claim_id,
        {{ j('c', '$.grp') }}   as grp,
        {{ j('c', '$.code') }}  as code
    from base, {{ explode('blob', '$.billing.remit.carc') }} as t(c)
),
denials as (
    select
        claim_id,
        bool_or(grp = 'CO' and code in ('50', '16', '11', '197'))                              as is_denied,
        max(case when grp = 'CO' and code in ('50', '16', '11', '197') then grp || '-' || code end) as denial_reason
    from carc
    group by 1
)
select
    base.claim_id,
    base.encounter_id,
    {{ jnum('blob', '$.billing.remit.paid') }}              as paid_amount_usd,
    coalesce(denials.is_denied, false)                     as is_denied,
    denials.denial_reason,
    {{ j('base.blob', '$.billing.remit.carc') }} as carc_json
from base
left join denials on base.claim_id = denials.claim_id
