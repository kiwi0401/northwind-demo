-- Coding-opportunity / data-quality view over diagnoses. Joins the conformed diagnosis union to
-- seed_icd10. The join only matches when diagnosis_code is in dotted ICD-10 form; codes left in
-- no-dot or pipe form show up as unmatched. unmatched_code_rate reports the rate per client.
with dx as (
    select * from {{ ref('int_all__diagnoses') }}
),
ref_codes as (
    select diagnosis_code, description, chronic_flag from {{ ref('seed_icd10') }}
),
joined as (
    select
        dx.client_key,
        dx.encounter_id,
        dx.diagnosis_code,
        dx.is_primary,
        dx.poa_flag,
        (ref_codes.diagnosis_code is not null) as code_in_reference,
        ref_codes.chronic_flag
    from dx
    left join ref_codes on dx.diagnosis_code = ref_codes.diagnosis_code
)
select
    client_key,
    count(*)                                                         as diagnosis_count,
    sum(case when code_in_reference then 0 else 1 end)              as unmatched_codes,
    round(sum(case when code_in_reference then 0 else 1 end) * 1.0 / count(*), 4) as unmatched_code_rate,
    sum(case when is_primary and poa_flag is null then 1 else 0 end) as primary_dx_missing_poa,
    sum(case when chronic_flag = 1 then 1 else 0 end)               as chronic_dx_count
from joined
group by 1
order by unmatched_code_rate desc
