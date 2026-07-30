-- Every summit service line charge must be a positive USD dollar amount.
-- Fails (returns rows) if any line has a null or non-positive charge after conforming.
select
    claim_id,
    encounter_id,
    line_no,
    charge_usd
from {{ ref('int_summit__service_lines') }}
where charge_usd is null or charge_usd <= 0
