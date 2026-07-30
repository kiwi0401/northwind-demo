-- Spot-check for JIRA-2214: finance said northstar charges looked light for one month.
-- Compares claim counts in the modeled fact against a raw count off the landing table.
-- TODO: remove after JIRA-2214 closes (2024-08).

with modeled as (
    select client_id, count(*) as modeled_claim_count
    from {{ ref('fct_org_claims') }}
    where client_id = 'northstar_health'
    group by 1
),
raw_blob as (
    select
        'northstar_health' as client_id,
        count(*)           as raw_blob_count
    from {{ source('raw', 'client_blob') }}
    where source_client = 'northstar_health'
)
select
    m.client_id,
    m.modeled_claim_count,
    r.raw_blob_count,
    r.raw_blob_count - m.modeled_claim_count as unmodeled_row_count
from modeled m
left join raw_blob r on m.client_id = r.client_id

-- original one-off also pulled the per-payer split, left here in case we reopen:
-- select json_extract_string(blob, '$.claim.payer_id') as payer_id, count(*)
-- from {{ source('raw', 'client_blob') }}
-- where source_client = 'northstar_health'
-- group by 1 order by 2 desc
