-- Procedure volume across clients from conformed service lines. Charge in USD dollars.
select
    procedure_code,
    count(*)                     as line_count,
    count(distinct claim_id)     as claim_count,
    sum(units)                   as total_units,
    round(sum(charge_usd), 2)    as total_charge_usd,
    round(avg(charge_usd), 2)    as avg_line_charge_usd
from {{ ref('int_all__service_lines') }}
group by 1
order by line_count desc
