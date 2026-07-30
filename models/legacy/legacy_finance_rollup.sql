-- Legacy finance rollup (pre-2024 migration). Superseded by fct_org_claims.
-- Kept for the monthly finance export. Do not extend.
-- Built straight off staging (this predates the intermediate layer). Only the first three
-- clients that went live were ever wired up; the later six were never added here.
{{ config(materialized='table') }}

with northstar as (
    select
        c.client_id,
        c.claim_id,
        c.total_charge_usd,
        coalesce(r.paid_amount_usd, 0)          as paid_amount_usd,
        coalesce(r.is_denied, false)            as is_denied
    from {{ ref('stg_northstar__claims') }} c
    left join {{ ref('stg_northstar__remittance') }} r on c.claim_id = r.claim_id
),
bayview as (
    select
        c.client_id,
        c.claim_id,
        c.total_charge_usd,
        coalesce(r.paid_amount_usd, 0)          as paid_amount_usd,
        coalesce(r.is_denied, false)            as is_denied
    from {{ ref('stg_bayview__claims') }} c
    left join {{ ref('stg_bayview__remittance') }} r on c.claim_id = r.claim_id
),
plains as (
    select
        c.client_id,
        c.claim_id,
        c.total_charge_usd,
        coalesce(r.paid_amount_usd, 0)          as paid_amount_usd,
        coalesce(r.is_denied, false)            as is_denied
    from {{ ref('stg_plains__claims') }} c
    left join {{ ref('stg_plains__remittance') }} r on c.claim_id = r.claim_id
)
select * from northstar
union all
select * from bayview
union all
select * from plains
