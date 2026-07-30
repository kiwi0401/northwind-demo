{#
    Use the bare custom schema name (staging / intermediate / marts / seeds)
    instead of dbt's default <target_schema>_<custom_schema> prefixing.

    The demo warehouse ships with these models pre-built on the shared `main`
    branch. A user's agent wires dbt via SignalPilot's get_dbt_profile tool,
    which picks the target schema (default "public") — with dbt's default
    prefixing, a rebuild would land in public_staging/public_marts and leave the
    pre-built staging/marts orphaned beside it. Pinning to the bare name makes
    the build location deterministic no matter what target schema is handed in,
    so a rebuild lands exactly on top of what shipped. Matches the parallax demo.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
