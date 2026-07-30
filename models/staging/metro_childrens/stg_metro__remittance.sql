-- Remittance grain (one 835 per claim). Money in USD DOLLARS.
-- Denial rule (dialect B): a carc[] entry with grp='CO' and code in (50,16,11,197) is a
-- denial; denial_reason = that grp||'-'||code. Other carc entries are routine adjustments
-- and are ignored. carc[] is exploded and aggregated back to claim grain here.
with base as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'metro_childrens'
),
carc as (
    select
        {{ j('blob', '$.billing.claim.claim_no') }} as claim_id,
        bool_or(
            {{ j('c', '$.grp') }} = 'CO'
            and {{ j('c', '$.code') }} in ('50', '16', '11', '197')
        ) as is_denied,
        max(case
            when {{ j('c', '$.grp') }} = 'CO' and {{ j('c', '$.code') }} in ('50', '16', '11', '197')
            then {{ j('c', '$.grp') }} || '-' || {{ j('c', '$.code') }}
        end) as denial_reason
    from base, {{ explode('blob', '$.billing.remit.carc') }} as t(c)
    group by 1
)
select
    {{ j('base.blob', '$.billing.claim.claim_no') }} as claim_id,
    {{ j('base.blob', '$.visit.visit_id') }}         as encounter_id,
    {{ jnum('base.blob', '$.billing.remit.paid') }}  as paid_amount_usd,
    coalesce(carc.is_denied, false)                  as is_denied,
    carc.denial_reason                               as denial_reason
from base
left join carc on {{ j('base.blob', '$.billing.claim.claim_no') }} = carc.claim_id
