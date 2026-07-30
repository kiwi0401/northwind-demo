-- NOTE: this duplicates stg_bayview__claims almost exactly. It was added before someone
-- noticed stg_bayview__claims already existed. Nothing downstream should depend on it;
-- use stg_bayview__claims instead. Left in place to avoid breaking any stray references.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'bayview_medical'
)
select
    {{ j('blob', '$.billing.claim.claim_no') }}   as claim_id,
    {{ j('blob', '$.visit.visit_id') }}           as encounter_id,
    'bayview_medical'                             as client_id,
    {{ j('blob', '$.billing.claim.bill_type') }}  as claim_format,
    {{ j('blob', '$.billing.claim.payer') }}      as payer_id,
    {{ jnum('blob', '$.billing.claim.charges') }} as total_charge_usd,
    {{ j('blob', '$.schema_version') }}           as schema_version
from src
