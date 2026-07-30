-- valley_care's diagnosis event `kind` name changes by schema_version
-- ('dx' v1.0 / 'diagnosis' v2.0 / 'diag' v3.0). Matching only kind='diagnosis' would capture
-- zero diagnoses for v1.0 and v3.0. This test fails if any schema_version that has
-- encounters has no diagnoses -- i.e. a kind name was dropped.
select e.schema_version
from (select distinct schema_version from {{ ref('stg_valley__encounters') }}) e
left join (select distinct schema_version from {{ ref('stg_valley__diagnoses') }}) d
    on e.schema_version = d.schema_version
where d.schema_version is null
