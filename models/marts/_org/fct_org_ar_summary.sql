-- Org-wide A/R summary: outstanding (unpaid) balance by client and payer type. Uses USD amounts
-- so cross-client A/R is comparable.
select
    client_id,
    coalesce(payer_type, 'unknown')       as payer_type,
    count(*)                              as claim_count,
    sum(total_charge_usd)                as charged_usd,
    sum(paid_amount_usd)                 as paid_usd,
    sum(unpaid_usd)                      as outstanding_ar_usd,
    sum(case when is_denied then unpaid_usd else 0 end) as denied_ar_usd
from {{ ref('fct_org_claims') }}
group by 1, 2
order by outstanding_ar_usd desc
