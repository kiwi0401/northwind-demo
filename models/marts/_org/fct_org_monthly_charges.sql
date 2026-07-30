-- Monthly charge/paid trend across clients (charges dated by encounter admit month).
with claims as (select * from {{ ref('fct_org_claims') }}),
enc as (select encounter_id, client_id, admit_ts from {{ ref('int_all__encounters') }})
select
    date_trunc('month', enc.admit_ts)          as charge_month,
    claims.client_id,
    count(*)                                   as claim_count,
    round(sum(claims.total_charge_usd), 2)     as total_charge_usd,
    round(sum(claims.paid_amount_usd), 2)      as total_paid_usd
from claims
join enc on claims.encounter_id = enc.encounter_id and claims.client_id = enc.client_id
where enc.admit_ts is not null
group by 1, 2
order by 1, 2
