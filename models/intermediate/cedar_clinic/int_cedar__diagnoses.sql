{{ config(materialized='view') }}
-- Conformed diagnosis grain: one row per (encounter, diagnosis). Resolves encounter_id from
-- the case_id carried on staging diagnoses. dx_seq/is_primary/canonical ICD/POA already set upstream.
with dx as (
    select * from {{ ref('stg_cedar__diagnoses') }}
),
enc as (
    select encounter_id, case_id from {{ ref('stg_cedar__encounters') }}
)
select
    enc.encounter_id,
    dx.dx_seq,
    dx.is_primary,
    dx.diagnosis_code,
    dx.poa_flag
from dx
join enc on dx.case_id = enc.case_id
