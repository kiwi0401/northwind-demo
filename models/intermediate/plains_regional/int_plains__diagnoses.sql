{{ config(materialized='view') }}
-- Conformed diagnosis grain (one row per encounter, diagnosis). Pass-through of the staging
-- diagnosis model, which already canonicalizes ICD to dotted and POA to Y/N/U.
select
    encounter_id,
    dx_seq,
    is_primary,
    diagnosis_code,
    poa_flag
from {{ ref('stg_plains__diagnoses') }}
