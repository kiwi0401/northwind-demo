-- Client-level encounter fact. One row per encounter.
select * from {{ ref('int_cedar__encounters') }}
