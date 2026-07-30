-- Unified DRG dimension. MS-DRG and APR-DRG numeric codes overlap (code "193" means different
-- things in each system), so the key is (drg_code, drg_type), not code alone.
-- cast drg_code to text: the seed loads it as integer, but blob-derived drg_code is text.
select drg_code::text as drg_code, drg_type, description, relative_weight
from {{ ref('seed_ms_drg') }}
union all
select drg_code::text as drg_code, drg_type, description, null as relative_weight
from {{ ref('seed_apr_drg') }}
