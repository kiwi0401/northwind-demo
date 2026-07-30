{{ config(materialized='view') }}
-- Conformed diagnosis grain: one row per (encounter, diagnosis). Staging already emits the
-- exact contract columns (dotted ICD via icd_canonical, canonical POA); this is a conforming pass-through.
select
    encounter_id,
    dx_seq,
    is_primary,
    diagnosis_code,
    poa_flag
from {{ ref('stg_riverside__diagnoses') }}
