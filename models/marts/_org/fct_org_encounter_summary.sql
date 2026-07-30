-- Encounter counts and mix by client and encounter type (conformed).
select
    client_id,
    encounter_type,
    count(*)                                as encounter_count,
    round(avg(diagnosis_count), 2)          as avg_diagnoses,
    round(avg(service_line_count), 2)       as avg_service_lines,
    sum(case when has_authorization then 1 else 0 end) as authorized_count
from {{ ref('int_all__encounters') }}
group by 1, 2
order by 1, 2
