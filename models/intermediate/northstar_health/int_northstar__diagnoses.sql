{{ config(materialized='view') }}
-- Conformed diagnosis grain (pass-through; ICD already canonicalized in staging).
select
    encounter_id,
    dx_seq,
    is_primary,
    diagnosis_code,
    poa_flag
from {{ ref('stg_northstar__diagnoses') }}
