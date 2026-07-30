{{ config(materialized='view') }}
-- Conformed service-line grain (pass-through; charge already USD in staging).
select
    claim_id,
    encounter_id,
    line_no,
    procedure_code,
    units,
    charge_usd
from {{ ref('stg_northstar__service_lines') }}
