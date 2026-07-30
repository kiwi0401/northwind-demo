-- Grain guard: int_plains__encounters must be exactly one row per encounter_id (anti-fan-out).
-- Fails (returns rows) if diagnoses or service_lines fan-out leaked into the encounter grain.
select
    encounter_id,
    count(*) as row_count
from {{ ref('int_plains__encounters') }}
group by 1
having count(*) > 1
