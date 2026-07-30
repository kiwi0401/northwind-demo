-- Harbor denial rate. Named f_ instead of fct_ (older naming). Redundant with the org denial
-- mart, which already covers harbor; this exists from before the org layer was built out.
select
    client_id,
    count(*)                                              as claim_count,
    sum(case when is_denied then 1 else 0 end)            as denied_count,
    round(sum(case when is_denied then 1 else 0 end) * 1.0 / count(*), 4) as denial_rate
from {{ ref('int_harbor__claim_financials') }}
group by 1
