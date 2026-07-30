-- Encounters where discharge_datetime < admission_datetime, i.e. a negative
-- length_of_stay_days (~2% of metro encounters). These rows are preserved upstream
-- (not clamped, not dropped) since the negative LOS is a data-quality flag reporting relies on.
-- Isolates them so downstream / the org layer can flag and quantify the dirty population.
select
    encounter_id,
    client_id,
    patient_ref,
    facility_id,
    encounter_type,
    admit_ts,
    discharge_ts,
    length_of_stay_days
from {{ ref('int_metro__encounters') }}
where length_of_stay_days < 0
