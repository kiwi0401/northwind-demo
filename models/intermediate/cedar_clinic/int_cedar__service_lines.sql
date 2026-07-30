{{ config(materialized='view') }}
-- Conformed service-line grain: one row per (claim, line). Resolves encounter_id from the
-- case_id carried on staging service lines. Charges already in USD dollars upstream.
with sl as (
    select * from {{ ref('stg_cedar__service_lines') }}
),
enc as (
    select encounter_id, case_id from {{ ref('stg_cedar__encounters') }}
)
select
    sl.claim_id,
    enc.encounter_id,
    sl.line_no,
    sl.procedure_code,
    sl.units,
    sl.charge_usd
from sl
left join enc on sl.case_id = enc.case_id
