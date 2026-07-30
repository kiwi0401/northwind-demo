{{ config(materialized='view') }}
-- Diagnosis grain (conformed contract): one row per (encounter, diagnosis).
-- Passthrough of the canonicalized staging model; ICD already dotted, pediatric POA already
-- canonicalized to Y/N/U. is_primary = dx_seq = 1.
select
    encounter_id,
    dx_seq,
    is_primary,
    diagnosis_code,
    poa_flag
from {{ ref('stg_metro__diagnoses') }}
