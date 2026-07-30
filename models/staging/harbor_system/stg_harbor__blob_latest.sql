-- Dedup driver. harbor_system = dialect B (visit-nested) with resubmissions: the same
-- visit_id lands multiple times with a top-level version_no (1, 2, ...) and corrected (bool).
-- The corrected (highest version_no) row supersedes the original. Keep only the highest
-- version_no per visit_id. Every other harbor staging model reads this model, so the dedup
-- happens once and no claim/charge/paid amount double-counts downstream.
-- Postgres has no QUALIFY: compute row_number() in a subquery, then filter rn = 1 outside.
with ranked as (
    select
        blob,
        {{ j('blob', '$.visit.visit_id') }}                as visit_id,
        ({{ j('blob', '$.version_no') }})::int             as version_no,
        ({{ j('blob', '$.corrected') }} = 'true')          as corrected,
        row_number() over (
            partition by {{ j('blob', '$.visit.visit_id') }}
            order by ({{ j('blob', '$.version_no') }})::int desc
        ) as rn
    from {{ source('raw', 'client_blob') }}
    where source_client = 'harbor_system'
)
select
    blob,
    visit_id,
    version_no,
    corrected
from ranked
where rn = 1
