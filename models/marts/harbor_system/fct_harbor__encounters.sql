-- Client-level encounter fact. One row per encounter (deduped visit).
select * from {{ ref('int_harbor__encounters') }}
