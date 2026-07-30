{# =========================================================================
   JSON access helpers for the verbatim raw.client_blob landing table (Postgres/jsonb).

   Every client sends a different shape, so staging models navigate the blob with these
   macros. Centralizing the Postgres jsonb idioms here keeps staging models readable.

   Postgres idioms:
     scalar : blob #>> '{a,b}'                                   (text at a path)
     number : nullif(replace(blob #>> '{a}', ',', ''), '')::numeric   (tolerates '1,250.00')
     array  : jsonb_array_elements(blob #> '{arr}')  AS t(elem)  (set-returning, in FROM)
     array+ : jsonb_array_elements(...) WITH ORDINALITY AS t(elem, n)  (1-based index)
   ========================================================================= #}

{# convert a JSONPath like '$.a.b[0].c' into a Postgres path-array literal '{a,b,0,c}' #}
{% macro pgpath(path) -%}
    {%- set cleaned = path.replace('$.', '').replace('[', '.').replace(']', '') -%}
    {%- set parts = [] -%}
    {%- for seg in cleaned.split('.') -%}
        {%- if seg != '' -%}{%- do parts.append(seg) -%}{%- endif -%}
    {%- endfor -%}
    '{ {{- parts | join(',') -}} }'
{%- endmacro %}

{# scalar text at a json path #}
{% macro j(col, path) -%}
    ({{ col }} #>> {{ pgpath(path) }})
{%- endmacro %}

{# numeric at a json path, tolerant of comma-formatted string money and integer cents. #}
{% macro jnum(col, path, is_cents=false) -%}
    {%- if is_cents -%}
        (nullif(replace({{ col }} #>> {{ pgpath(path) }}, ',', ''), '')::numeric / 100.0)
    {%- else -%}
        nullif(replace({{ col }} #>> {{ pgpath(path) }}, ',', ''), '')::numeric
    {%- endif -%}
{%- endmacro %}

{# set-returning array expansion — use in FROM:  {{ explode('blob','$.arr') }} as t(elem) #}
{% macro explode(col, path) -%}
    jsonb_array_elements({{ col }} #> {{ pgpath(path) }})
{%- endmacro %}

{# array expansion with a 1-based ordinal — use:  {{ explode_ord('blob','$.arr') }} as t(elem, seq) #}
{% macro explode_ord(col, path) -%}
    jsonb_array_elements({{ col }} #> {{ pgpath(path) }}) with ordinality
{%- endmacro %}

{# length of a json array at a path #}
{% macro jarr_len(col, path) -%}
    jsonb_array_length({{ col }} #> {{ pgpath(path) }})
{%- endmacro %}

{# whole-day length of stay between two timestamp expressions #}
{% macro date_diff_days(admit, discharge) -%}
    (({{ discharge }})::date - ({{ admit }})::date)
{%- endmacro %}

{# parse an ISO-8601 string (optionally trailing 'Z') to a timestamp #}
{% macro ts_iso(expr) -%}
    (replace({{ expr }}, 'Z', ''))::timestamp
{%- endmacro %}

{# parse epoch-milliseconds text to a timestamp #}
{% macro ts_epoch_ms(expr) -%}
    to_timestamp(({{ expr }})::bigint / 1000.0)::timestamp
{%- endmacro %}

{# split a delimited string into an array (unnest() works on Postgres arrays) #}
{% macro str_split(expr, delim) -%}
    string_to_array({{ expr }}, '{{ delim }}')
{%- endmacro %}

{# normalize an ICD-10 code to dotted canonical form regardless of how the client sent it. #}
{% macro icd_canonical(expr) -%}
    case
        when {{ expr }} is null or length({{ expr }}) < 4 then {{ expr }}
        when position('.' in {{ expr }}) > 0 then {{ expr }}
        else substr({{ expr }}, 1, 3) || '.' || substr({{ expr }}, 4)
    end
{%- endmacro %}

{# canonicalize a POA flag: clients send Y/N/U/W or 1/0 -> Y/N/U #}
{% macro poa_canonical(expr) -%}
    case
        when {{ expr }} in ('Y','1') then 'Y'
        when {{ expr }} in ('N','0') then 'N'
        when {{ expr }} in ('U','W') then 'U'
        else null
    end
{%- endmacro %}
