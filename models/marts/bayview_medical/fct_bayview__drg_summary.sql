-- APR-DRG mart. Aggregates encounters by (drg_code, drg_type) so the org layer can key
-- DRG joins on the pair (drg_code, drg_type) -- APR-DRG and MS-DRG code sets overlap numerically,
-- so code alone is ambiguous across clients. bayview is 100% APR-DRG.
select
    drg_code,
    drg_type,
    'bayview_medical'                     as client_id,
    count(*)                              as encounter_count,
    sum(service_line_charge_usd)          as total_charge_usd,
    avg(length_of_stay_days)              as avg_length_of_stay_days
from {{ ref('int_bayview__encounters') }}
where drg_code is not null
group by 1, 2, 3
