-- Facility dimension. Distinct facilities (visit.location_id) seen across encounters, with
-- their encounter volume for convenience.
select
    facility_id,
    'bayview_medical'      as client_id,
    count(*)               as encounter_count
from {{ ref('int_bayview__encounters') }}
where facility_id is not null
group by 1, 2
