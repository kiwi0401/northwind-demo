-- The dirty-LOS mart must contain exactly the negative-LOS encounters and nothing else.
-- (We do not assert los >= 0 anywhere: negative LOS is an expected metro data-quality issue.)
-- This test fails if any row in fct_metro__dirty_los has a non-negative length_of_stay_days,
-- or if any negative-LOS encounter in the fact is missing from the dirty mart.
with dirty as (
    select encounter_id, length_of_stay_days from {{ ref('fct_metro__dirty_los') }}
),
neg_in_fact as (
    select encounter_id from {{ ref('fct_metro__encounters') }}
    where length_of_stay_days < 0
)
select encounter_id from dirty where length_of_stay_days >= 0
union all
select encounter_id from neg_in_fact
where encounter_id not in (select encounter_id from dirty)
