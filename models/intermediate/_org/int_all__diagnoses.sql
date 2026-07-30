{{ config(materialized='view') }}
-- Cross-client conformed diagnosis union. diagnosis_code should be in dotted ICD-10 form for
-- every client, otherwise the join to seed_icd10 in fct_org_coding_opportunities won't match.
{% set clients = ['northstar', 'bayview', 'cedar', 'plains', 'harbor', 'summit', 'riverside', 'metro', 'valley'] %}

{% for c in clients %}
select
    encounter_id,
    '{{ c }}'          as client_key,
    dx_seq,
    is_primary,
    diagnosis_code,
    poa_flag
from {{ ref('int_' ~ c ~ '__diagnoses') }}
{% if not loop.last %}union all{% endif %}
{% endfor %}
