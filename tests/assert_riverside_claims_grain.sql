-- Grain guard: int_riverside__claim_financials must be exactly one row per claim_id.
-- Fails (returns rows) if a remittance join fanned out or claims are duplicated.
select
    claim_id,
    count(*) as row_count
from {{ ref('int_riverside__claim_financials') }}
group by 1
having count(*) > 1
