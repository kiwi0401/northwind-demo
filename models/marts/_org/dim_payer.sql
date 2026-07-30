-- Canonical payer dimension. Built from the payer seed. The payer_xref seed resolves
-- riverside_health's local P0x codes; all other clients already send canonical codes.
with payers as (
    select payer_id, payer_name, payer_type from {{ ref('seed_payers') }}
)
select
    payer_id,
    payer_name,
    payer_type
from payers
