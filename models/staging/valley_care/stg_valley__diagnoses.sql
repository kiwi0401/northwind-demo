-- Diagnosis grain. Dialect-C drift: the diagnosis event `kind` name changes by version --
-- 'dx' (v1.0), 'diagnosis' (v2.0), 'diag' (v3.0). Accept all three, otherwise v1 and v3 rows
-- are dropped. ICD is sent without the dot -> icd_canonical dots it. v3.0 drops the `poa`
-- field entirely -> poa_flag is null for v3 rows (handled via poa_canonical).
-- dx_seq is the 1-based order of diagnosis events within the case (row_number over original index).
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'valley_care'
),
events as (
    select
        {{ j('blob', '$.case_id') }}        as case_id,
        {{ j('blob', '$.schema_version') }} as schema_version,
        ev,
        ev_idx
    from src, {{ explode_ord('blob', '$.events') }} as t(ev, ev_idx)
),
dx as (
    select case_id, schema_version, ev, ev_idx
    from events
    where {{ j('ev', '$.kind') }} in ('dx', 'diagnosis', 'diag')
)
select
    case_id,
    row_number() over (partition by case_id order by ev_idx)       as dx_seq,
    (row_number() over (partition by case_id order by ev_idx) = 1) as is_primary,
    {{ icd_canonical(j('ev', '$.code')) }}                         as diagnosis_code,
    {{ poa_canonical(j('ev', '$.poa')) }}                          as poa_flag,
    schema_version
from dx
