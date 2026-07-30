-- Claim grain integrity: metro has no resubmissions (unlike harbor), so claim_id must be
-- unique in the conformed claim model. Fails if any claim_id appears more than once.
select claim_id
from {{ ref('int_metro__claim_financials') }}
group by claim_id
having count(*) > 1
