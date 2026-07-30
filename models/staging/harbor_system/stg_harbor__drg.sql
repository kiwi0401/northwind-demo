-- DRG grain (one per encounter). Dialect B sends an APR-DRG scalar at billing.codes.drg_apr.
-- drg_type is 'APR-DRG' when a code is present, else null (contract requires null when absent).
with src as (
    select blob from {{ ref('stg_harbor__blob_latest') }}
)
select
    {{ j('blob', '$.visit.visit_id') }}          as encounter_id,
    {{ j('blob', '$.billing.codes.drg_apr') }}   as drg_code,
    case
        when {{ j('blob', '$.billing.codes.drg_apr') }} is not null then 'APR-DRG'
    end                                          as drg_type
from src
