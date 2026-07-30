-- Clinical document grain (1..3 per encounter).
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'plains_regional'
)
select
    {{ j('blob', '$.encounter.encounter_id') }}  as encounter_id,
    {{ j('doc', '$.doc_id') }}                   as doc_id,
    {{ j('doc', '$.type') }}                     as doc_type,
    {{ j('doc', '$.author_role') }}              as author_role,
    {{ j('doc', '$.text') }}                     as doc_text
from src, {{ explode('blob', '$.documentation') }} as t(doc)
