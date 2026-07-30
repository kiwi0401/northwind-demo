-- Facility dimension: distinct facilities metro sends (visit.location_id), with encounter volume.
select
    facility_id,
    client_id,
    count(*)                                as encounter_count,
    count(distinct encounter_type)          as encounter_type_count
from {{ ref('int_metro__encounters') }}
where facility_id is not null
group by 1, 2
