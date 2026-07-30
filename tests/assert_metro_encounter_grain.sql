-- Encounter grain integrity: int_metro__encounters must be exactly one row per encounter
-- after pre-aggregating fan-out children. Fails if any encounter_id is duplicated.
select encounter_id
from {{ ref('int_metro__encounters') }}
group by encounter_id
having count(*) > 1
