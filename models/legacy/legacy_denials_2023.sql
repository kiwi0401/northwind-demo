-- Legacy denial-rate rollup. Deprecated: replaced by fct_org_denial_rate_by_payer.
-- Reads legacy_finance_rollup, so it inherits the same 3-of-9-client gap. Client-level grain.
{{ config(materialized='table') }}

select
    client_id,
    count(*)                                              as claim_count,
    sum(case when is_denied then 1 else 0 end)            as denied_count,
    round(sum(case when is_denied then 1 else 0 end) * 1.0 / count(*), 4) as denial_rate
from {{ ref('legacy_finance_rollup') }}
group by 1
order by client_id
