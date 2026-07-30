{{ config(materialized='view') }}
-- Conformed service-line grain (one row per claim, line). Pass-through of staging, which
-- already converts comma-string charges to USD dollars.
select
    claim_id,
    encounter_id,
    line_no,
    procedure_code,
    units,
    charge_usd
from {{ ref('stg_plains__service_lines') }}
