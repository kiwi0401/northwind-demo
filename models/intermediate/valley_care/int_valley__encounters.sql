-- Conformed encounter grain (EXACTLY one row per encounter). Fan-out children (diagnoses,
-- service_lines) are aggregated to case grain in CTEs BEFORE joining, to prevent row multiplication.
-- Children are keyed by case_id (the dialect-C linking key); we join them to the encounter on case_id.
-- Dialect C sends no DRG and no authorization block: drg_* null, auth_status null, has_authorization false.
with enc as (
    select * from {{ ref('stg_valley__encounters') }}
),
dx as (
    select
        case_id,
        max(case when is_primary then diagnosis_code end) as primary_diagnosis_code,
        count(*)                                          as diagnosis_count
    from {{ ref('stg_valley__diagnoses') }}
    group by 1
),
lines as (
    select
        case_id,
        count(*)         as service_line_count,
        sum(charge_usd)  as service_line_charge_usd
    from {{ ref('stg_valley__service_lines') }}
    group by 1
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
    cast(null as varchar)                             as drg_code,
    cast(null as varchar)                             as drg_type,
    dx.primary_diagnosis_code,
    coalesce(dx.diagnosis_count, 0)                   as diagnosis_count,
    coalesce(lines.service_line_count, 0)             as service_line_count,
    coalesce(lines.service_line_charge_usd, 0)        as service_line_charge_usd,
    cast(null as varchar)                             as auth_status,
    false                                             as has_authorization
from enc
left join dx    on enc.case_id = dx.case_id
left join lines on enc.case_id = lines.case_id
