-- Service-line grain (fan-out driver). Dialect C: explode events[], keep kind='charge'.
-- charge events carry claim_id (not encounter id); case_id is carried so intermediate can
-- resolve the encounter via case_id. Money is in dollars -> jnum without is_cents.
select
    {{ j('blob', '$.case_id') }}                    as case_id,
    {{ j('ev', '$.claim_id') }}                     as claim_id,
    ({{ j('ev', '$.line') }})::int                  as line_no,
    {{ j('ev', '$.code') }}                         as procedure_code,
    ({{ j('ev', '$.units') }})::int                 as units,
    {{ jnum('ev', '$.amount') }}                    as charge_usd
from {{ source('raw', 'client_blob') }},
     {{ explode('blob', '$.events') }} as t(ev)
where source_client = 'cedar_clinic'
  and {{ j('ev', '$.kind') }} = 'charge'
