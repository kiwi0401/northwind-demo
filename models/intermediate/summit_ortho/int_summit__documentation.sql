-- Conformed documentation grain: one row per (encounter, document). Passthrough of the
-- semicolon-split staging documents; summit sends only a doc type label (no id/author/text).
select
    encounter_id,
    doc_seq,
    doc_type
from {{ ref('stg_summit__documents') }}
