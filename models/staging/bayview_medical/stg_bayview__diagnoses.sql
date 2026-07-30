-- Diagnosis grain. bayview sends ICD without the decimal point (e.g. 'J189') -> icd_canonical
-- dots it. POA arrives as 1/0 -> poa_canonical maps to Y/N. dx_seq via WITH ORDINALITY (1-based).
with src as (
    select
        {{ j('cb.blob', '$.visit.visit_id') }}  as encounter_id,
        t.dx                                    as dx,
        t.dx_seq                                as dx_seq
    from {{ source('raw', 'client_blob') }} cb,
         {{ explode_ord('cb.blob', '$.billing.codes.dx') }} as t(dx, dx_seq)
    where cb.source_client = 'bayview_medical'
)
select
    encounter_id,
    dx_seq,
    (dx_seq = 1)                              as is_primary,
    {{ icd_canonical(j('dx', '$.icd')) }}     as diagnosis_code,
    {{ poa_canonical(j('dx', '$.poa')) }}     as poa_flag
from src
