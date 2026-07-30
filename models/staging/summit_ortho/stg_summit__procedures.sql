-- Procedure grain. px_list is a pipe-delimited string "27447|0SRC0J9" (CPT and/or ICD-10-PCS
-- mixed, sent as codes). Explode on '|'. Empty string -> single '' token, filtered out.
-- Procedure codes are kept as sent (no ICD dotting: mixes CPT which never dots).
with src as (
    select
        {{ j('blob', '$.account.acct_id') }}                        as encounter_id,
        t.px_code                                                  as px_code
    from {{ source('raw', 'client_blob') }},
         unnest({{ str_split(j('blob', '$.px_list'), '|') }}) as t(px_code)
    where source_client = 'summit_ortho'
)
select
    encounter_id,
    px_code as procedure_code
from src
where px_code <> ''
