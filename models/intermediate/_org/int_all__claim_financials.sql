-- Cross-client conformed claim union. Amounts already normalized to USD per client; payer_id is
-- still the raw client code (canonicalized in fct_org_claims via payer_xref). is_denied is set per each client's rule.
{% set clients = ['northstar', 'bayview', 'cedar', 'plains', 'harbor', 'summit', 'riverside', 'metro', 'valley'] %}

{% for c in clients %}
select
    claim_id,
    encounter_id,
    client_id,
    claim_format,
    payer_id,
    total_charge_usd,
    paid_amount_usd,
    is_denied,
    unpaid_usd,
    denial_reason
from {{ ref('int_' ~ c ~ '__claim_financials') }}
{% if not loop.last %}union all{% endif %}
{% endfor %}
