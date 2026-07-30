-- Service-line grain; 1..N charges per encounter. charges[] carry no
-- explicit line number, so line_no is the 1-based array position (parallel positional unnest).
-- Charges also carry no claim reference; the claim is attached downstream in intermediate.
-- Money is already in USD dollars.
with src as (
    select
        {{ j('cb.blob', '$.account.acct_id') }}                                                 as encounter_id,
        t.charge                                                                                as charge,
        t.line_no                                                                               as line_no
    from {{ source('raw', 'client_blob') }} cb,
         {{ explode_ord('cb.blob', '$.charges') }} as t(charge, line_no)
    where cb.source_client = 'summit_ortho'
)
select
    encounter_id,
    line_no,
    {{ j('charge', '$.cpt') }}                    as procedure_code,
    {{ j('charge', '$.mod') }}                    as modifier,
    ({{ j('charge', '$.qty') }})::int             as units,
    {{ jnum('charge', '$.amt') }}                 as charge_usd
from src
