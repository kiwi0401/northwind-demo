-- Facility dimension. Distinct facilities as sent on the encounter event, with encounter
-- volume and the set of encounter types seen. cedar sends facility as a free-text code.
select
    facility_id,
    client_id,
    count(*)                          as encounter_count,
    count(distinct encounter_type)    as encounter_type_count
from {{ ref('int_cedar__encounters') }}
where facility_id is not null
group by facility_id, client_id
