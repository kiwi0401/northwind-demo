{{ config(materialized='view') }}
-- Conformed diagnosis grain (one row per encounter+diagnosis). Passthrough of staging, which
-- already canonicalized ICD to dotted and POA 1/0 -> Y/N/U. is_primary = dx_seq = 1.
select
    encounter_id,
    dx_seq,
    is_primary,
    diagnosis_code,
    poa_flag
from {{ ref('stg_bayview__diagnoses') }}
