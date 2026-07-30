{{ config(materialized='view') }}
-- Cross-client conformed service-line union. charge_usd in USD dollars for every client.
{% set clients = ['northstar', 'bayview', 'cedar', 'plains', 'harbor', 'summit', 'riverside', 'metro', 'valley'] %}

{% for c in clients %}
select
    claim_id,
    encounter_id,
    '{{ c }}'        as client_key,
    line_no,
    procedure_code,
    units,
    charge_usd
from {{ ref('int_' ~ c ~ '__service_lines') }}
{% if not loop.last %}union all{% endif %}
{% endfor %}
