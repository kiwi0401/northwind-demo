-- Diagnosis grain. plains_regional sends dotted ICD-10-CM already; canonicalize defensively.
-- dx_seq comes from WITH ORDINALITY (1-based array position); seq=1 = primary.
with src as (
    select
        {{ j('cb.blob', '$.encounter.encounter_id') }}  as encounter_id,
        t.dx                                            as dx,
        t.dx_seq                                        as dx_seq
    from {{ source('raw', 'client_blob') }} cb,
         {{ explode_ord('cb.blob', '$.coding.diagnoses') }} as t(dx, dx_seq)
    where cb.source_client = 'plains_regional'
)
select
    encounter_id,
    dx_seq,
    (dx_seq = 1)                              as is_primary,
    {{ icd_canonical(j('dx', '$.code')) }}    as diagnosis_code,
    {{ poa_canonical(j('dx', '$.poa')) }}     as poa_flag
from src
