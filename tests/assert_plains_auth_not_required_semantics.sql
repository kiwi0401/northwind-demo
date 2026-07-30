-- The absent-authorization -> 'not_required' mapping must hold exactly. An encounter is
-- 'not_required' if and only if it has no authorization block (has_authorization = false), and
-- every encounter with an authorization block has a real status (never 'not_required').
-- Fails (returns rows) on any encounter that violates the not-required rule.
select
    encounter_id,
    auth_status,
    has_authorization
from {{ ref('int_plains__encounters') }}
where (auth_status = 'not_required' and has_authorization)
   or (auth_status <> 'not_required' and not has_authorization)
