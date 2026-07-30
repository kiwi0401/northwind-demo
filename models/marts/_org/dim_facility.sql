-- Org-wide facility dimension. Facilities are client-local ids, so the key is (client_id, facility_id).
select distinct client_id, facility_id
from {{ ref('int_all__encounters') }}
where facility_id is not null
