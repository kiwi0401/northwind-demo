-- Diagnosis grain. Dialect C: explode events[], keep kind='diagnosis'. ICD sent dotted;
-- canonicalize defensively. dx_seq = array order among diagnosis events (1 = primary).
-- ev_idx preserves original array position (1-based ordinal from explode_ord over $.events).
with exploded as (
    select
        {{ j('cb.blob', '$.case_id') }}  as case_id,
        t.ev                             as ev,
        t.ev_idx                         as ev_idx
    from {{ source('raw', 'client_blob') }} cb,
         {{ explode_ord('cb.blob', '$.events') }} as t(ev, ev_idx)
    where cb.source_client = 'cedar_clinic'
),
dx as (
    select case_id, ev, ev_idx
    from exploded
    where {{ j('ev', '$.kind') }} = 'diagnosis'
)
select
    case_id,
    row_number() over (partition by case_id order by ev_idx)         as dx_seq,
    (row_number() over (partition by case_id order by ev_idx) = 1)   as is_primary,
    {{ icd_canonical(j('ev', '$.code')) }}                           as diagnosis_code,
    {{ poa_canonical(j('ev', '$.poa')) }}                            as poa_flag
from dx
