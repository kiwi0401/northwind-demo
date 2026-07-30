-- Grain guard: int_cedar__encounters must be exactly one row per encounter (no fan-out from
-- joining pre-aggregated diagnoses / service_lines). Returns any duplicated encounter_id.
select encounter_id, count(*) as n
from {{ ref('int_cedar__encounters') }}
group by encounter_id
having count(*) > 1
