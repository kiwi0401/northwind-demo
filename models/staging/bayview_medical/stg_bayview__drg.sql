-- DRG grain (one per encounter). bayview sends billing.codes.drg_apr as a scalar APR-DRG code
-- (not the {code,type} object dialect A uses). drg_type is fixed to 'APR-DRG'.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'bayview_medical'
)
select
    {{ j('blob', '$.visit.visit_id') }}          as encounter_id,
    {{ j('blob', '$.billing.codes.drg_apr') }}   as drg_code,
    'APR-DRG'                                    as drg_type
from src
