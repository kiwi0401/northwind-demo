-- Exec revenue report. The "one table finance opens every Monday". Stitches the per-client
-- charge, A/R and denial marts together and bolts the legacy rollup on the side so finance can
-- see where the old numbers disagree. Grew column by column over two years; alias style is
-- whatever each person used at the time. Owned by nobody in particular.
{{ config(materialized='table') }}

with cli as (
    select
        client_id,
        claim_count,
        total_charge_usd,
        total_paid_usd,
        total_unpaid_usd,
        collection_rate
    from {{ ref('fct_org_charges_by_client') }}
),

-- outstanding A/R rolled up from the payer-type grain back to one row per client
t1 as (
    select
        client_id,
        sum(outstanding_ar_usd) as outstanding_ar_usd
    from {{ ref('fct_org_ar_summary') }}
    group by 1
),

-- legacy rollup summarized per client so we can show the delta vs the current charge number.
-- only three clients exist over here, so the delta is null for the other six.
a as (
    select
        client_id,
        sum(total_charge_usd) as legacy_total_charge_usd
    from {{ ref('legacy_finance_rollup') }}
    group by 1
)

select
    cli.client_id,
    cli.claim_count,
    cli.total_charge_usd,
    cli.total_paid_usd,
    cli.total_unpaid_usd,
    cli.collection_rate,
    t1.outstanding_ar_usd,
    -- single overall denial rate across the whole org, same value on every row (cross join)
    (select round(sum(denied_count) * 1.0 / nullif(sum(claim_count), 0), 4)
       from {{ ref('fct_org_denial_rate_by_payer') }}) as org_denial_rate,
    a.legacy_total_charge_usd,
    cli.total_charge_usd - a.legacy_total_charge_usd     as legacy_vs_current_charge_delta
from cli
left join t1 on cli.client_id = t1.client_id
left join a  on cli.client_id = a.client_id
order by cli.total_charge_usd desc
