-- Conformed encounter grain (one row per encounter). Aggregates the fan-out children
-- (diagnoses, service_lines) to encounter grain before joining, to avoid multiplying rows.
-- Authorizations carry 'not_required' when the block was absent (a valid state).
with enc as (
    select * from {{ ref('stg_plains__encounters') }}
),
drg as (
    select * from {{ ref('stg_plains__drg') }}
),
dx as (
    select
        encounter_id,
        max(case when is_primary then diagnosis_code end) as primary_diagnosis_code,
        count(*)                                          as diagnosis_count
    from {{ ref('stg_plains__diagnoses') }}
    group by 1
),
lines as (
    select
        encounter_id,
        count(*)          as service_line_count,
        sum(charge_usd)   as service_line_charge_usd
    from {{ ref('stg_plains__service_lines') }}
    group by 1
),
auth as (
    select * from {{ ref('stg_plains__authorizations') }}
)
select
    enc.encounter_id,
    enc.client_id,
    enc.patient_ref,
    enc.facility_id,
    enc.encounter_type,
    enc.admit_ts,
    enc.discharge_ts,
    {{ date_diff_days('enc.admit_ts', 'enc.discharge_ts') }}  as length_of_stay_days,
    drg.drg_code,
    drg.drg_type,
    dx.primary_diagnosis_code,
    coalesce(dx.diagnosis_count, 0)                       as diagnosis_count,
    coalesce(lines.service_line_count, 0)                 as service_line_count,
    coalesce(lines.service_line_charge_usd, 0)            as service_line_charge_usd,
    -- absent auth already normalized to 'not_required' in staging; coalesce guards a missing row
    coalesce(auth.auth_status, 'not_required')            as auth_status,
    coalesce(auth.has_authorization, false)               as has_authorization
from enc
left join drg   on enc.encounter_id = drg.encounter_id
left join dx    on enc.encounter_id = dx.encounter_id
left join lines on enc.encounter_id = lines.encounter_id
left join auth  on enc.encounter_id = auth.encounter_id
