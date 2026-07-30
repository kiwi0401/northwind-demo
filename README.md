# Northwind — SignalPilot demo warehouse

Northwind is a fictional healthcare revenue-cycle company. This dbt project
builds its warehouse: staging -> intermediate -> marts across ~190 models
(encounters, claims, charges, denials, payers, remits).

It is the companion repo for the SignalPilot demo: the demo connection you
added in SignalPilot is a **private copy-on-write branch** of this warehouse —
query it, break it, rebuild it. Removing the connection deletes the branch.

## Setup

```bash
git clone https://github.com/kiwi0401/northwind-demo
cd northwind-demo
python -m pip install dbt-postgres
```

## Connect

1. In SignalPilot, open the **/demo-db** page and add the **Northwind** demo
   warehouse (once per workspace).
2. Go to **Settings -> API Keys**, create a key, and copy the MCP connection
   URL + snippet shown there to hook up your agent (Claude Code, Cursor, ...).
3. Point dbt at your branch:

```bash
export NORTHWIND_PG_HOST=<branch-id>.<region>.xata.tech
export NORTHWIND_PG_USER=xata
export NORTHWIND_PG_PASSWORD=<branch password>

dbt debug
dbt build
```

Your agent can hand you these values directly — ask it for the dbt profile and
it will call SignalPilot's `get_dbt_profile` tool.

## What's in here

Every client sends its encounters as a **verbatim JSON blob**, and each one uses
a different on-the-wire shape. There is exactly one source table:

| source | description |
| --- | --- |
| `raw.client_blob` | `source_client`, `load_id`, `blob` — one row per encounter document, exactly as the client sent it |

All parsing happens in dbt. Staging materializes as tables so the JSON is parsed
once; intermediate is views; marts are tables.

```
models/
  staging/        79 models — one set per client dialect, parses raw.client_blob
  intermediate/   43 models — conforms the client shapes into shared grain
  marts/          61 models — claims, charges, denials, payer performance
  reporting/       1 model  — exec revenue report
  adhoc/           3 models — scratch work someone left behind
  legacy/          2 models — superseded, still referenced
  spider/          1 model  — fct_claim_360, a very wide "everything" mart
```

The warehouse is deliberately **imperfect**. `adhoc/`, `legacy/` and `spider/`
are not tidy, and they are not meant to be: they are the kind of thing that
accumulates in a real warehouse, and they are useful for seeing how an agent
copes with a codebase nobody has curated.

## Rebuilding on top of what shipped

The demo branch arrives with these models already built. `macros/generate_schema_name.sql`
pins models to the bare schema names (`staging`, `intermediate`, `marts`) rather
than dbt's default `<target>_<schema>` prefixing, so a `dbt build` lands exactly
on top of what shipped instead of orphaning it beside a `public_staging` copy.
