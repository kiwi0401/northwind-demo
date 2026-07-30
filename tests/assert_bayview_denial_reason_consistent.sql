-- Denial rule check: a claim flagged is_denied must carry a denial_reason, and a claim not
-- denied must not carry one. Fails (returns rows) on any inconsistency between the two fields.
select
    claim_id,
    is_denied,
    denial_reason
from {{ ref('int_bayview__claim_financials') }}
where (is_denied and denial_reason is null)
   or (not is_denied and denial_reason is not null)
