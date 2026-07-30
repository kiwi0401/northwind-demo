-- Diagnosis grain. Dialect B sends ICD without a decimal point ('J189') -> icd_canonical dots it.
-- POA may arrive as 1/0 -> poa_canonical. dx_seq via positional multi-unnest; seq=1 = primary.
-- Reads the deduped blob so a resubmitted visit does not double its diagnosis rows.
with src as (
    select
        {{ j('cb.blob', '$.visit.visit_id') }}  as encounter_id,
        t.dx                                    as dx,
        t.dx_seq                                as dx_seq
    from {{ ref('stg_harbor__blob_latest') }} cb,
         {{ explode_ord('cb.blob', '$.billing.codes.dx') }} as t(dx, dx_seq)
)
select
    encounter_id,
    dx_seq,
    (dx_seq = 1)                              as is_primary,
    {{ icd_canonical(j('dx', '$.icd')) }}     as diagnosis_code,
    {{ poa_canonical(j('dx', '$.poa')) }}     as poa_flag
from src
