-- Grain guard: int_plains__claim_financials must be exactly one row per claim_id.
-- Fails (returns rows) if any claim_id appears more than once.
select
    claim_id,
    count(*) as row_count
from {{ ref('int_plains__claim_financials') }}
group by 1
having count(*) > 1
