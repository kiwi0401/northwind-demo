-- Conformed encounter grain: one row per encounter. Fan-out children (diagnoses,
-- service_lines) are pre-aggregated to case grain in CTEs before joining, so joins cannot
-- multiply rows. Dialect C children carry case_id (not encounter_id); resolve via case_id.
-- cedar sends no DRG, no patient id, and no authorization -> those conform to null/false.
with enc as (
    select * from {{ ref('stg_cedar__encounters') }}
),
dx as (
    select
        case_id,
        max(case when is_primary then diagnosis_code end) as primary_diagnosis_code,
        count(*)                                          as diagnosis_count
    from {{ ref('stg_cedar__diagnoses') }}
    group by case_id
),
lines as (
    select
        case_id,
        count(*)          as service_line_count,
        sum(charge_usd)   as service_line_charge_usd
    from {{ ref('stg_cedar__service_lines') }}
    group by case_id
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
    cast(null as varchar)                             as drg_code,   -- cedar sends no DRG
    cast(null as varchar)                             as drg_type,
    dx.primary_diagnosis_code,
    coalesce(dx.diagnosis_count, 0)                   as diagnosis_count,
    coalesce(lines.service_line_count, 0)             as service_line_count,
    coalesce(lines.service_line_charge_usd, 0)        as service_line_charge_usd,
    cast(null as varchar)                             as auth_status,       -- cedar sends no auth
    false                                             as has_authorization
from enc
left join dx    on enc.case_id = dx.case_id
left join lines on enc.case_id = lines.case_id
