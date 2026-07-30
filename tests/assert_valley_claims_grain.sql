-- Grain guard: int_valley__claim_financials must be exactly one row per claim (no fan-out from
-- the charge->payment join). Returns any duplicated claim_id.
select claim_id, count(*) as n
from {{ ref('int_valley__claim_financials') }}
group by claim_id
having count(*) > 1
