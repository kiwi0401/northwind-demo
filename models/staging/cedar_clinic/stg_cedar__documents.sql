-- Clinical document grain. Dialect C: explode events[], keep kind='note' (text only).
-- doc_seq gives a stable within-case ordinal (dialect C notes carry no id/type).
with exploded as (
    select
        {{ j('cb.blob', '$.case_id') }}  as case_id,
        t.ev                             as ev,
        t.ev_idx                         as ev_idx
    from {{ source('raw', 'client_blob') }} cb,
         {{ explode_ord('cb.blob', '$.events') }} as t(ev, ev_idx)
    where cb.source_client = 'cedar_clinic'
),
notes as (
    select case_id, ev, ev_idx
    from exploded
    where {{ j('ev', '$.kind') }} = 'note'
)
select
    case_id,
    row_number() over (partition by case_id order by ev_idx)  as doc_seq,
    {{ j('ev', '$.text') }}                                   as doc_text
from notes
