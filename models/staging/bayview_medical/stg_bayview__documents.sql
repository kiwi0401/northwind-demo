-- Clinical document grain (notes[] on dialect B). Fields are {id, kind, text}; there is no
-- author_role in this dialect (left null to keep the conformed doc shape stable).
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'bayview_medical'
)
select
    {{ j('blob', '$.visit.visit_id') }}  as encounter_id,
    {{ j('note', '$.id') }}              as doc_id,
    {{ j('note', '$.kind') }}            as doc_type,
    cast(null as varchar)               as author_role,
    {{ j('note', '$.text') }}           as doc_text
from src, {{ explode('blob', '$.notes') }} as t(note)
