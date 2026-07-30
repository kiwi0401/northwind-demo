-- Procedure grain (kind='procedure'). Only a `code` is sent in this dialect. May be empty.
with src as (
    select blob from {{ source('raw', 'client_blob') }}
    where source_client = 'valley_care'
)
select
    {{ j('blob', '$.case_id') }}        as case_id,
    {{ j('ev', '$.code') }}             as procedure_code,
    {{ j('blob', '$.schema_version') }} as schema_version
from src, {{ explode('blob', '$.events') }} as t(ev)
where {{ j('ev', '$.kind') }} = 'procedure'
