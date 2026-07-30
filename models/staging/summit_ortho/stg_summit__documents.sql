-- Clinical document grain. docs is a semicolon-delimited string "H&P; Op Note" (not a
-- JSON array). Split on '; ' and explode with a positional index. Empty string filtered out.
with src as (
    select
        {{ j('blob', '$.account.acct_id') }}                                              as encounter_id,
        t.doc_type                                                                       as doc_type,
        t.doc_seq                                                                        as doc_seq
    from {{ source('raw', 'client_blob') }},
         unnest({{ str_split(j('blob', '$.docs'), '; ') }}) with ordinality as t(doc_type, doc_seq)
    where source_client = 'summit_ortho'
)
select
    encounter_id,
    doc_seq,
    doc_type
from src
where doc_type <> ''
