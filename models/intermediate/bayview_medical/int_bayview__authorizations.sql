-- Conformed authorization grain (one row per encounter). Passthrough of staging auth block.
-- has_authorization reflects block presence; absence = not sent (distinct from not_required).
select
    encounter_id,
    auth_id,
    auth_status,
    has_authorization
from {{ ref('stg_bayview__authorizations') }}
