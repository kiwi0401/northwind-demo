-- Mart for the plains_regional auth pattern: the $.authorization block is absent ~40% of
-- the time, and absence means "not required" (a valid clinical/billing state, not missing data).
-- One row per encounter that did not require prior authorization. has_authorization is false here
-- because these encounters are authorized by exemption, so they must not be counted
-- as auth gaps downstream. Contrast with 'pending'/'denied', which are real authorization risk.
select
    enc.encounter_id,
    enc.client_id,
    enc.facility_id,
    enc.encounter_type,
    enc.admit_ts,
    enc.primary_diagnosis_code,
    enc.drg_code,
    enc.auth_status,          -- 'not_required'
    enc.has_authorization     -- false, and that is correct
from {{ ref('int_plains__encounters') }} enc
where enc.auth_status = 'not_required'
