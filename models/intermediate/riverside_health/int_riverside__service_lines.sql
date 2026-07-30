{{ config(materialized='view') }}
-- Conformed service-line grain: one row per (claim, line). Staging already emits USD dollars
-- (cents ÷100) and the exact contract columns; this is a conforming pass-through.
select
    claim_id,
    encounter_id,
    line_no,
    procedure_code,
    units,
    charge_usd
from {{ ref('stg_riverside__service_lines') }}
