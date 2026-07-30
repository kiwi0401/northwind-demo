-- Cross-client encounter grain: (client_id, encounter_id) must be unique in the conformed union.
-- Catches harbor resubmission dedup failures and any client fan-out leak into the encounter model.
select client_id, encounter_id, count(*) as n
from {{ ref('int_all__encounters') }}
group by 1, 2
having count(*) > 1
