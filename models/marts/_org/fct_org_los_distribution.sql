-- Length-of-stay distribution by client. Includes a negative bucket; metro_childrens has some
-- negative-LOS rows from data-quality issues upstream.
with e as (select * from {{ ref('int_all__encounters') }})
select
    client_id,
    sum(case when length_of_stay_days < 0 then 1 else 0 end)                        as los_negative,
    sum(case when length_of_stay_days = 0 then 1 else 0 end)                        as los_same_day,
    sum(case when length_of_stay_days between 1 and 3 then 1 else 0 end)            as los_1_3,
    sum(case when length_of_stay_days between 4 and 7 then 1 else 0 end)            as los_4_7,
    sum(case when length_of_stay_days > 7 then 1 else 0 end)                        as los_8_plus,
    round(avg(length_of_stay_days), 2)                                             as avg_los_days
from e
group by 1
order by client_id
