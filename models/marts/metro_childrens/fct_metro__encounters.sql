-- Client-level encounter fact. One row per encounter. LOS may be negative (dirty rows preserved).
select * from {{ ref('int_metro__encounters') }}
