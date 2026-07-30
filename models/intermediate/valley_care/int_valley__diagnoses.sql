{{ config(materialized='view') }}
-- Conformed diagnosis grain (one row per encounter, diagnosis). Maps the case-keyed staging
-- diagnoses to encounter_id via the encounter stage. Accepts all three drifting kind names
-- upstream; v3 rows arrive with poa_flag null and pass through unchanged.
with dx as (
    select * from {{ ref('stg_valley__diagnoses') }}
),
enc as (
    select case_id, encounter_id from {{ ref('stg_valley__encounters') }}
)
select
    enc.encounter_id,
    dx.dx_seq,
    dx.is_primary,
    dx.diagnosis_code,
    dx.poa_flag
from dx
join enc on dx.case_id = enc.case_id
