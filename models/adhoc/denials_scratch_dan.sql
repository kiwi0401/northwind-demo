-- quick pull for the QBR, don't build on this
select
    client_id,
    count(*) as claims,
    sum(denied) as denials,
    round(sum(denied) * 1.0 / count(*), 4) as denial_rate
from (
    select
        client_id,
        case when is_denied = true then 1 else 0 end as denied
    from (
        select client_id, is_denied
        from {{ ref('int_all__claim_financials') }}
    ) x
) y
group by client_id
order by denial_rate desc
