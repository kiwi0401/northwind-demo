-- Service-line charges are dollars and must never be negative for cedar_clinic.
select claim_id, line_no, charge_usd
from {{ ref('int_cedar__service_lines') }}
where charge_usd < 0
