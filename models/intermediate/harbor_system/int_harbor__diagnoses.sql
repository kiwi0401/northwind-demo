{{ config(materialized='view') }}
-- Conformed diagnosis grain: one row per (encounter, diagnosis). Codes already canonicalized to
-- dotted ICD-10 and POA normalized to Y/N/U in staging.
select
    encounter_id,
    dx_seq,
    is_primary,
    diagnosis_code,
    poa_flag
from {{ ref('stg_harbor__diagnoses') }}
