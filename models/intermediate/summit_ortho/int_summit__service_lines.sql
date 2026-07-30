{{ config(materialized='view') }}
-- Conformed service-line grain: one row per (claim, line). summit charges carry no claim ref,
-- so each encounter's lines are attached to its primary claim (claim_seq = 1). This keeps the
-- (claim, line) grain and makes claim charge totals reconcile with the service lines.
with lines as (
    select * from {{ ref('stg_summit__service_lines') }}
),
primary_claim as (
    select encounter_id, claim_id
    from {{ ref('stg_summit__claims') }}
    where claim_seq = 1
)
select
    pc.claim_id,
    l.encounter_id,
    l.line_no,
    l.procedure_code,
    l.units,
    l.charge_usd
from lines l
left join primary_claim pc on l.encounter_id = pc.encounter_id
