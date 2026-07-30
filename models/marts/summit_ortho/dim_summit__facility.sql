-- Facility dimension. Distinct top-level facility_id values seen for summit_ortho.
select distinct
    facility_id,
    client_id
from {{ ref('int_summit__encounters') }}
where facility_id is not null
