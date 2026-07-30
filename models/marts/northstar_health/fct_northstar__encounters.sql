-- Client-level encounter fact. One row per encounter.
select * from {{ ref('int_northstar__encounters') }}
