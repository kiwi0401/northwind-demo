-- Cross-client conformed encounter union. Every client's int_<c>__encounters must expose
-- these exact columns so the union lines up.
{% set clients = ['northstar', 'bayview', 'cedar', 'plains', 'harbor', 'summit', 'riverside', 'metro', 'valley'] %}

{% for c in clients %}
select
    encounter_id,
    client_id,
    patient_ref,
    facility_id,
    encounter_type,
    admit_ts,
    discharge_ts,
    length_of_stay_days,
    drg_code,
    drg_type,
    primary_diagnosis_code,
    diagnosis_count,
    service_line_count,
    service_line_charge_usd,
    auth_status,
    has_authorization
from {{ ref('int_' ~ c ~ '__encounters') }}
{% if not loop.last %}union all{% endif %}
{% endfor %}
