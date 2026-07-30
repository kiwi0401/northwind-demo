-- Authorization grain (one per encounter). auth block carries {auth_id, status}.
-- has_authorization = the auth block was sent. Absence here means "not sent" (missing data),
-- not the "not required" semantics that plains_regional uses.
with src as (
    select blob from {{ ref('stg_harbor__blob_latest') }}
)
select
    {{ j('blob', '$.visit.visit_id') }}            as encounter_id,
    {{ j('blob', '$.auth.auth_id') }}             as auth_id,
    {{ j('blob', '$.auth.status') }}              as auth_status,
    (blob #> '{auth}') is not null                as has_authorization
from src
