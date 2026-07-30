-- Procedure grain. Dialect C: explode events[], keep kind='procedure' (code only).
-- proc_seq gives a stable within-case ordinal for uniqueness. No code system is sent.
with exploded as (
    select
        {{ j('cb.blob', '$.case_id') }}  as case_id,
        t.ev                             as ev,
        t.ev_idx                         as ev_idx
    from {{ source('raw', 'client_blob') }} cb,
         {{ explode_ord('cb.blob', '$.events') }} as t(ev, ev_idx)
    where cb.source_client = 'cedar_clinic'
),
px as (
    select case_id, ev, ev_idx
    from exploded
    where {{ j('ev', '$.kind') }} = 'procedure'
)
select
    case_id,
    row_number() over (partition by case_id order by ev_idx)  as proc_seq,
    {{ j('ev', '$.code') }}                                   as procedure_code
from px
