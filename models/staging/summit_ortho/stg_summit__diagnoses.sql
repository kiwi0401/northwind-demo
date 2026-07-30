-- Diagnosis grain. dx_list is a pipe-delimited string "M1711|E119|I10" (no system,
-- no dots). Explode with string_split + parallel positional unnest for dx_seq (seq=1 = primary).
-- Codes have no dots -> icd_canonical. There is no per-dx POA in this dialect -> poa_flag null.
-- Empty dx_list -> single '' token, filtered out (encounter simply has no diagnoses).
with src as (
    select
        {{ j('blob', '$.account.acct_id') }}                                                       as encounter_id,
        t.dx_code                                                                                  as dx_code,
        t.dx_seq                                                                                   as dx_seq
    from {{ source('raw', 'client_blob') }},
         unnest({{ str_split(j('blob', '$.dx_list'), '|') }}) with ordinality as t(dx_code, dx_seq)
    where source_client = 'summit_ortho'
)
select
    encounter_id,
    dx_seq,
    (dx_seq = 1)                          as is_primary,
    {{ icd_canonical('dx_code') }}        as diagnosis_code,
    cast(null as varchar)                 as poa_flag
from src
where dx_code <> ''
