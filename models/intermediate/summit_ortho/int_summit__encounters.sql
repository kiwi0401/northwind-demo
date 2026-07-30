-- Conformed encounter grain (one row per acct_id). Fan-out children (diagnoses,
-- service_lines) are pre-aggregated to encounter grain in CTEs before joining, to avoid
-- multiplying rows. summit has no DRG and no authorization -> those columns are null/false.
with enc as (
    select * from {{ ref('stg_summit__encounters') }}
),
dx as (
    select
        encounter_id,
        max(case when is_primary then diagnosis_code end) as primary_diagnosis_code,
        count(distinct diagnosis_code)                    as diagnosis_count
    from {{ ref('int_summit__diagnoses') }}
    group by 1
),
lines as (
    select
        encounter_id,
        count(*)         as service_line_count,
        sum(charge_usd)  as service_line_charge_usd
    from {{ ref('stg_summit__service_lines') }}
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
    cast(null as varchar)                              as drg_code,
    cast(null as varchar)                              as drg_type,
    dx.primary_diagnosis_code,
    coalesce(dx.diagnosis_count, 0)                    as diagnosis_count,
    coalesce(lines.service_line_count, 0)              as service_line_count,
    coalesce(lines.service_line_charge_usd, 0)         as service_line_charge_usd,
    cast(null as varchar)                              as auth_status,
    false                                              as has_authorization
from enc
left join dx    on enc.encounter_id = dx.encounter_id
left join lines on enc.encounter_id = lines.encounter_id
