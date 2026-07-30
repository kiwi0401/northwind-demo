{{ config(materialized='view') }}
-- Service-line grain (conformed contract): one row per (claim, line).
-- Passthrough of staging; amounts already in USD dollars, units already int.
select
    claim_id,
    encounter_id,
    line_no,
    procedure_code,
    units,
    charge_usd
from {{ ref('stg_metro__service_lines') }}
