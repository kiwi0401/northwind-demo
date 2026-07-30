-- Clinical document grain (kind='note'). Only free-text `text` is sent; no doc id or type.
-- note_seq is the 1-based order of note events within the case.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'valley_care'
),
events as (
    select
        {{ j('blob', '$.case_id') }}        as case_id,
        ev,
        ev_idx
    from src, {{ explode_ord('blob', '$.events') }} as t(ev, ev_idx)
)
select
    case_id,
    row_number() over (partition by case_id order by ev_idx) as note_seq,
    {{ j('ev', '$.text') }}                                  as doc_text
from events
where {{ j('ev', '$.kind') }} = 'note'
