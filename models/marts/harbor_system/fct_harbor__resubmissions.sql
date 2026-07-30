-- Resubmission fact (one row per visit_id) built from the un-deduped version log. Shows the
-- original (version_no=1) vs the corrected final (highest version_no): how many versions were
-- superseded and the paid delta the correction introduced. Rows with superseded_version_count > 0
-- are the ones that would double-count if a downstream sum did not dedup first.
with versions as (
    select * from {{ ref('stg_harbor__resubmissions') }}
),
agg as (
    select
        encounter_id,
        count(*)                                    as version_count,
        count(*) - 1                                as superseded_version_count,
        max(version_no)                             as final_version_no,
        bool_or(corrected)                          as ever_corrected,
        (array_agg(claim_id order by version_no asc))[1]         as original_claim_id,
        (array_agg(claim_id order by version_no desc))[1]        as final_claim_id,
        (array_agg(paid_amount_usd order by version_no asc))[1]  as original_paid_usd,
        (array_agg(paid_amount_usd order by version_no desc))[1] as final_paid_usd,
        (array_agg(total_charge_usd order by version_no asc))[1] as original_charge_usd,
        (array_agg(total_charge_usd order by version_no desc))[1] as final_charge_usd
    from versions
    group by encounter_id
)
select
    encounter_id,
    'harbor_system'                          as client_id,
    version_count,
    superseded_version_count,
    final_version_no,
    ever_corrected,
    (version_count > 1)                      as was_resubmitted,
    original_claim_id,
    final_claim_id,
    original_paid_usd,
    final_paid_usd,
    final_paid_usd - original_paid_usd       as paid_delta_usd,
    original_charge_usd,
    final_charge_usd,
    final_charge_usd - original_charge_usd    as charge_delta_usd
from agg
