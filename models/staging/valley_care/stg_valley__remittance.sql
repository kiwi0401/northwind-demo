-- Remittance grain (kind='payment', one per claim). Money is USD DOLLARS.
-- Denial rule (dialect C): is_denied = paid == 0 (the rule for v1/v3). v2.0 also
-- carries an explicit `denial` bool which we keep raw for cross-checking, but paid==0 is the rule.
-- denial_reason = first element of the carc[] array if present (may be a routine adjustment code).
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'valley_care'
)
select
    {{ j('ev', '$.claim_id') }}                 as claim_id,
    {{ j('blob', '$.case_id') }}                as case_id,
    {{ jnum('ev', '$.paid') }}                  as paid_amount_usd,
    ({{ jnum('ev', '$.paid') }} = 0)            as is_denied,
    {{ j('ev', '$.denial') }}                   as denial_flag_raw,   -- present only in v2.0, else null
    {{ j('ev', '$.carc[0]') }}                  as denial_reason,
    {{ j('blob', '$.schema_version') }}         as schema_version
from src, {{ explode('blob', '$.events') }} as t(ev)
where {{ j('ev', '$.kind') }} = 'payment'
