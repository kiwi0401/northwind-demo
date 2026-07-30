-- Service-line grain (kind='charge'; fan-out driver, many charge lines per claim/case).
-- Money is USD DOLLARS (no cents conversion). Charges reference claim_id; case_id is carried
-- so the intermediate layer can map the line back to its encounter.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'valley_care'
)
select
    {{ j('ev', '$.claim_id') }}                   as claim_id,
    {{ j('blob', '$.case_id') }}                  as case_id,
    ({{ j('ev', '$.line') }})::int                as line_no,
    {{ j('ev', '$.code') }}                       as procedure_code,
    ({{ j('ev', '$.units') }})::int               as units,
    {{ jnum('ev', '$.amount') }}                  as charge_usd
from src, {{ explode('blob', '$.events') }} as t(ev)
where {{ j('ev', '$.kind') }} = 'charge'
