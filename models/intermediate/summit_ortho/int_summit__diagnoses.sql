{{ config(materialized='view') }}
-- Conformed diagnosis grain: one row per (encounter, diagnosis). Staging already conforms
-- (dotted ICD, positional dx_seq, null POA), so this is a thin passthrough to the contract.
select
    encounter_id,
    dx_seq,
    is_primary,
    diagnosis_code,
    poa_flag
from {{ ref('stg_summit__diagnoses') }}
