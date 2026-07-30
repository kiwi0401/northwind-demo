{{ config(materialized='view') }}
-- Conformed service-line grain (one row per claim, line). Maps case-keyed staging charge lines
-- to encounter_id via the encounter stage. Money already USD dollars.
with lines as (
    select * from {{ ref('stg_valley__service_lines') }}
),
enc as (
    select case_id, encounter_id from {{ ref('stg_valley__encounters') }}
)
select
    lines.claim_id,
    enc.encounter_id,
    lines.line_no,
    lines.procedure_code,
    lines.units,
    lines.charge_usd
from lines
join enc on lines.case_id = enc.case_id
