{{ config(materialized='view') }}
-- Conformed service-line grain (one row per claim+line). Passthrough of staging; amounts are
-- already USD dollars, so no unit conversion is applied.
select
    claim_id,
    encounter_id,
    line_no,
    procedure_code,
    units,
    charge_usd
from {{ ref('stg_bayview__service_lines') }}
