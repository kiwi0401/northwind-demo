-- Procedure grain (ICD-10-PCS). May be empty for some encounters.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'northstar_health'
)
select
    {{ j('blob', '$.encounter.encounter_id') }}  as encounter_id,
    {{ j('proc', '$.code') }}                    as procedure_code,
    {{ j('proc', '$.system') }}                  as code_system
from src, {{ explode('blob', '$.coding.procedures') }} as t(proc)
