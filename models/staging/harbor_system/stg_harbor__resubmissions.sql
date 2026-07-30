-- Resubmission log (one row per submitted version). Reads the raw source directly, not
-- stg_harbor__blob_latest, because it must retain every version of every visit so the
-- resubmissions mart can compare the original (version_no=1) against the corrected final version.
-- This is the only harbor staging model that is not deduped.
select
    {{ j('blob', '$.visit.visit_id') }}               as encounter_id,
    {{ j('blob', '$.billing.claim.claim_no') }}       as claim_id,
    ({{ j('blob', '$.version_no') }})::int             as version_no,
    ({{ j('blob', '$.corrected') }} = 'true')         as corrected,
    {{ jnum('blob', '$.billing.claim.charges') }}     as total_charge_usd,
    {{ jnum('blob', '$.billing.remit.paid') }}        as paid_amount_usd
from {{ source('raw', 'client_blob') }}
where source_client = 'harbor_system'
