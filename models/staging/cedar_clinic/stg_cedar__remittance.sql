-- Remittance grain (one row per claim). Dialect C: explode events[], keep kind='payment'.
-- is_denied = paid == 0 (zero-pay client). v2.0 also carries an explicit 'denial' bool,
-- but v1/v3 don't, so we infer from paid==0 and keep the raw flag only for lineage.
-- denial_reason = first carc[] element if present. Money is in dollars.
select
    {{ j('ev', '$.claim_id') }}                          as claim_id,
    {{ j('blob', '$.case_id') }}                         as case_id,
    {{ jnum('ev', '$.paid') }}                           as paid_amount_usd,
    ({{ jnum('ev', '$.paid') }} = 0)                     as is_denied,
    ({{ j('ev', '$.denial') }})::boolean                 as denial_flag_raw,   -- v2 only; not used for is_denied
    {{ j('ev', '$.carc[0]') }}                           as denial_reason,
    {{ j('ev', '$.carc') }}                              as denial_carc_json
from {{ source('raw', 'client_blob') }},
     {{ explode('blob', '$.events') }} as t(ev)
where source_client = 'cedar_clinic'
  and {{ j('ev', '$.kind') }} = 'payment'
