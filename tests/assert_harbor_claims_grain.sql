-- Guards harbor_system resubmission dedup.
-- After version dedup there must be exactly one claim per claim_id and one encounter per visit_id.
-- If the dedup (highest version_no per visit_id) were skipped, a resubmitted visit would appear
-- multiple times and its claim_id / encounter_id would repeat here -> the test would return rows.
-- A zero-row result confirms the conformed models are deduped and cannot double-count.
with dup_claims as (
    select 'claim_id' as grain, claim_id as key
    from {{ ref('int_harbor__claim_financials') }}
    group by claim_id
    having count(*) > 1
),
dup_encounters as (
    select 'encounter_id' as grain, encounter_id as key
    from {{ ref('int_harbor__encounters') }}
    group by encounter_id
    having count(*) > 1
)
select * from dup_claims
union all
select * from dup_encounters
