-- Canonical diagnosis dimension from the ICD-10 seed. Join key is the dotted ICD-10 code; any
-- client whose codes were not normalized to dotted form won't match here (see fct_org_coding_opportunities).
select
    diagnosis_code,
    description,
    chronic_flag
from {{ ref('seed_icd10') }}
