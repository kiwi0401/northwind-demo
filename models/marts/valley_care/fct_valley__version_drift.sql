-- Version-drift observability mart. One row per schema_version.
-- Quantifies the drift: encounter volume per version, diagnosis rows captured per version
-- (which drop to zero for a version if only one kind name was matched), and the poa-null
-- rate that rises to 100% in v3.0 where the poa field was dropped.
-- Reads staging (schema_version is dropped from the conformed contract).
with enc as (
    select schema_version, count(*) as encounter_rows
    from {{ ref('stg_valley__encounters') }}
    group by 1
),
dx as (
    select
        schema_version,
        count(*)                                    as diagnosis_rows,
        count(*) filter (where poa_flag is null)    as poa_null_rows
    from {{ ref('stg_valley__diagnoses') }}
    group by 1
)
select
    coalesce(enc.schema_version, dx.schema_version)                   as schema_version,
    coalesce(enc.encounter_rows, 0)                                   as encounter_rows,
    coalesce(dx.diagnosis_rows, 0)                                    as diagnosis_rows,
    coalesce(dx.poa_null_rows, 0)                                     as poa_null_rows,
    round(100.0 * dx.poa_null_rows / nullif(dx.diagnosis_rows, 0), 1) as poa_null_pct
from enc
full outer join dx on enc.schema_version = dx.schema_version
order by schema_version
