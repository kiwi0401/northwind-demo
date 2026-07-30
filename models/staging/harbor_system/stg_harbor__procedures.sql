-- Procedure grain (ICD-10-PCS under billing.codes.px[].icd_pcs). May be empty.
with src as (
    select blob from {{ ref('stg_harbor__blob_latest') }}
)
select
    {{ j('blob', '$.visit.visit_id') }}  as encounter_id,
    {{ j('px', '$.icd_pcs') }}           as procedure_code,
    'ICD-10-PCS'                         as code_system
from src, {{ explode('blob', '$.billing.codes.px') }} as t(px)
