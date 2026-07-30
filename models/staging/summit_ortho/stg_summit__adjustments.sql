-- Adjustment grain: one row per payments[].adj[] entry. adj amounts are negative on the
-- wire -> abs() for reporting magnitude. is_denial_code applies the denial rule
-- (grp='CO' and rsn in 50/16/11/197); all other CARC codes are routine adjustments.
-- Nested lateral unnest: explode payments[], then explode each payment's adj[].
with payments as (
    select
        {{ j('blob', '$.account.acct_id') }}  as encounter_id,
        pay
    from {{ source('raw', 'client_blob') }}, {{ explode('blob', '$.payments') }} as t(pay)
    where source_client = 'summit_ortho'
)
select
    encounter_id,
    {{ j('pay', '$.claim') }}                                              as claim_id,
    {{ j('a', '$.grp') }}                                                  as adj_group,
    {{ j('a', '$.rsn') }}                                                  as adj_reason,
    {{ j('a', '$.grp') }} || '-' || {{ j('a', '$.rsn') }}                  as carc_code,
    {{ jnum('a', '$.amt') }}                                               as adj_amount_raw,
    abs({{ jnum('a', '$.amt') }})                                         as adj_amount_usd,
    ({{ j('a', '$.grp') }} = 'CO' and {{ j('a', '$.rsn') }} in ('50','16','11','197')) as is_denial_code
from payments, {{ explode('pay', '$.adj') }} as t(a)
