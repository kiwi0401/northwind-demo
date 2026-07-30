-- DRG grain (one per encounter). riverside uses MS-DRG.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'riverside_health'
)
select
    {{ j('blob', '$.encounter.encounter_id') }}  as encounter_id,
    {{ j('blob', '$.coding.drg.code') }}         as drg_code,
    {{ j('blob', '$.coding.drg.type') }}         as drg_type
from src
