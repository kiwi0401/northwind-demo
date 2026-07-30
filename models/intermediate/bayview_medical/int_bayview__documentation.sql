-- Conformed documentation grain (one row per clinical note). Passthrough of staging notes[].
select
    encounter_id,
    doc_id,
    doc_type,
    author_role,
    doc_text
from {{ ref('stg_bayview__documents') }}
