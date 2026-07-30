-- The pipe-split diagnosis exploder must never emit an empty-string diagnosis code.
-- Fails if the '' filter regressed (empty dx_list would otherwise leak a blank code).
select
    encounter_id,
    dx_seq,
    diagnosis_code
from {{ ref('int_summit__diagnoses') }}
where diagnosis_code is null or diagnosis_code = ''
