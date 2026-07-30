{{ config(materialized='view') }}
-- Conformed service-line grain: one row per (claim, line). Money already USD dollars.
select
    claim_id,
    encounter_id,
    line_no,
    procedure_code,
    units,
    charge_usd
from {{ ref('stg_harbor__service_lines') }}
