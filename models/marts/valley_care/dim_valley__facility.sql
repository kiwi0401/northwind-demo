-- Facility dimension. One row per distinct facility seen on valley_care encounters.
select
    facility_id,
    'valley_care'          as client_id,
    count(*)               as encounter_count
from {{ ref('int_valley__encounters') }}
where facility_id is not null
group by facility_id
