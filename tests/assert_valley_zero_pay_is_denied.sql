-- valley's denial rule: a claim paid 0 must be flagged is_denied.
-- Any claim with paid_amount_usd = 0 that is not denied is a conformance failure.
select claim_id
from {{ ref('int_valley__claim_financials') }}
where paid_amount_usd = 0
  and is_denied = false
