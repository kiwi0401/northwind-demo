-- Org-wide claim fact. Canonicalizes payer across clients: riverside's P0x codes map via
-- payer_xref; all others pass through. Joins the canonical payer dimension and encounter context.
with claims as (
    select * from {{ ref('int_all__claim_financials') }}
),
xref as (
    select source_client, local_payer_code, payer_id as canonical_payer_id
    from {{ ref('seed_payer_xref') }}
),
mapped as (
    select
        claims.*,
        coalesce(xref.canonical_payer_id, claims.payer_id) as canonical_payer_id
    from claims
    left join xref
        on claims.client_id = xref.source_client
       and claims.payer_id = xref.local_payer_code
),
enc as (
    select encounter_id, client_id, facility_id, encounter_type, drg_code, drg_type
    from {{ ref('int_all__encounters') }}
)
select
    mapped.claim_id,
    mapped.encounter_id,
    mapped.client_id,
    mapped.claim_format,
    mapped.payer_id                                as raw_payer_id,
    mapped.canonical_payer_id,
    payer.payer_name,
    payer.payer_type,
    (payer.payer_id is null)                       as payer_unmapped,   -- true = payer code never resolved
    mapped.total_charge_usd,
    mapped.paid_amount_usd,
    mapped.unpaid_usd,
    mapped.is_denied,
    mapped.denial_reason,
    enc.facility_id,
    enc.encounter_type,
    enc.drg_code,
    enc.drg_type
from mapped
left join {{ ref('dim_payer') }} payer on mapped.canonical_payer_id = payer.payer_id
left join enc on mapped.encounter_id = enc.encounter_id and mapped.client_id = enc.client_id
