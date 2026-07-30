-- riverside payer id counts, straight off the blob
select
  blob #>> '{claim,payer_id}' as payer_id,
  count(*) as n
from {{ source('raw', 'client_blob') }}
where source_client = 'riverside_health'
group by 1
order by n desc
