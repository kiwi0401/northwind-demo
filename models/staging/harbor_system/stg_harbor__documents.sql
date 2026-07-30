-- Clinical document grain. Dialect B carries free-text notes under notes[] as {id, kind, text}.
with src as (
    select blob from {{ ref('stg_harbor__blob_latest') }}
)
select
    {{ j('blob', '$.visit.visit_id') }}  as encounter_id,
    {{ j('note', '$.id') }}              as doc_id,
    {{ j('note', '$.kind') }}            as doc_type,
    {{ j('note', '$.text') }}            as doc_text
from src, {{ explode('blob', '$.notes') }} as t(note)
