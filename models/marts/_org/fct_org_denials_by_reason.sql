-- Denial breakdown by CARC reason across clients. Joins seed_carc to confirm each denial_reason is
-- a true-denial code (is_denial=1); routine adjustments should not appear here when upstream is correct.
with d as (
    select client_id, denial_reason
    from {{ ref('fct_org_claims') }}
    where is_denied and denial_reason is not null
)
select
    d.denial_reason,
    coalesce(c.description, 'UNKNOWN')  as reason_description,
    coalesce(c.is_denial, 0)           as seed_marks_denial,
    count(*)                           as denied_claim_count,
    count(distinct d.client_id)        as client_count
from d
left join {{ ref('seed_carc') }} c on d.denial_reason = c.carc_code
group by 1, 2, 3
order by denied_claim_count desc
