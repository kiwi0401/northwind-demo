-- Procedure grain (ICD-10-PCS). bayview sends px[] with an icd_pcs field. May be empty.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'bayview_medical'
)
select
    {{ j('blob', '$.visit.visit_id') }}  as encounter_id,
    {{ j('proc', '$.icd_pcs') }}         as procedure_code,
    'ICD-10-PCS'                         as code_system
from src, {{ explode('blob', '$.billing.codes.px') }} as t(proc)
