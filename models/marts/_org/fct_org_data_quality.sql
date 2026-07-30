-- Org-wide data-quality scorecard used by the ops team. Per-client counts of negative LOS,
-- unmapped payer codes, unknown DRG pairs, and missing charges. Rebuilt weekly.
with enc as (
    select * from {{ ref('int_all__encounters') }}
),
drg_ref as (
    select distinct drg_code, drg_type from {{ ref('dim_drg') }}
),
claims as (
    select client_id, sum(case when payer_unmapped then 1 else 0 end) as unmapped_payer_claims,
           count(*) as claim_count
    from {{ ref('fct_org_claims') }}
    group by 1
)
select
    enc.client_id,
    count(*)                                                                as encounter_count,
    sum(case when enc.length_of_stay_days < 0 then 1 else 0 end)            as negative_los_encounters,
    sum(case when enc.drg_code is not null and drg_ref.drg_code is null then 1 else 0 end) as unknown_drg_encounters,
    sum(case when enc.primary_diagnosis_code is null then 1 else 0 end)     as missing_primary_dx,
    sum(case when enc.service_line_charge_usd = 0 then 1 else 0 end)        as zero_charge_encounters,
    max(claims.unmapped_payer_claims)                                       as unmapped_payer_claims
from enc
left join drg_ref on enc.drg_code = drg_ref.drg_code and enc.drg_type = drg_ref.drg_type
left join claims on enc.client_id = claims.client_id
group by 1
order by negative_los_encounters desc
