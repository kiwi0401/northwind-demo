# Northwind — agent brief

## The business

Northwind is a healthcare revenue-cycle company. It bills insurers (payers) on behalf of nine client
health systems and tracks encounters, claims, charges, payments, denials and accounts receivable.
Every client sends encounters as raw JSON in its own shape (`raw.client_blob`); dbt parses and
conforms them. Clients are identified by long ids such as `bayview_medical` or `riverside_health`.

## Where the models live

Postgres warehouse. Schemas are pinned to bare names by `macros/generate_schema_name.sql`:

- `marts` — tables; start here.
- `intermediate` — views that conform the client shapes (`int_all__*` are the cross-client unions).
- `staging` — tables that parse the JSON; avoid for analysis.
- `seeds` — reference data (`seed_payers`, `seed_payer_xref`, `seed_carc`, `seed_icd10`, DRG seeds).
- `analytics` (the target schema) — unconfigured folders land here: `reporting`, `adhoc`, `legacy`, `spider`.

## Main marts and their grain

| Model | Grain |
|---|---|
| `marts.fct_org_claims` | one row per claim per client, `(client_id, claim_id)` |
| `intermediate.int_all__encounters` | one row per encounter per client, `(client_id, encounter_id)` |
| `marts.fct_org_denial_rate_by_payer` | one row per canonical payer |
| `marts.denial_rate_summary` | one row per client |
| `marts.fct_org_charges_by_client` | one row per client |
| `marts.fct_org_ar_summary` | one row per client and payer type |
| `marts.fct_org_monthly_charges` | one row per admit month and client |
| `marts.fct_org_denials_by_reason` | one row per CARC denial reason |
| `marts.fct_org_encounter_summary` | one row per client and encounter type |
| `marts.dim_payer`, `marts.dim_facility`, `marts.dim_drg`, `marts.dim_diagnosis` | dimensions |

Each client also has its own marts in `marts` named `fct_<client>__claims`, `fct_<client>__encounters`,
`fct_<client>__denials` and `dim_<client>__facility` (for example `fct_harbor__claims`). Use them only
for client-specific questions; use the `fct_org_*` models for anything cross-client.

## Rules for most questions

- **Money**: use the `_usd` columns (`total_charge_usd`, `paid_amount_usd`, `unpaid_usd`). They are
  normalized per client; raw staging amounts are in mixed units (cents, strings).
- **Dates**: `fct_org_claims` has no date column. Date claims by the encounter `admit_ts` from
  `intermediate.int_all__encounters`, joined on both `client_id` and `encounter_id`. This is how
  `fct_org_monthly_charges` dates charges.
- **Keys**: `claim_id` and `encounter_id` are unique only within a client. Always join and count on
  `client_id` together with the id.
- **Payers**: use `canonical_payer_id`, `payer_name` and `payer_type`, not `raw_payer_id`.
  Riverside sends local `P0x` codes that map through `seed_payer_xref`. `payer_unmapped = true` marks
  payers that never resolved; report them as unknown rather than dropping them silently.
- **Denials**: `is_denied` already applies each client's own rule (CARC array, CO-group code,
  zero payment or explicit flag). Do not re-derive it. `denial_reason` is a CARC code; describe it
  with `seeds.seed_carc`.
- **Length of stay**: `metro_childrens` has rows with negative length of stay (dirty data). Exclude
  negative values from averages and say so.
- **DRG**: MS-DRG and APR-DRG codes overlap numerically. Always pair `drg_code` with `drg_type`.
- **Harbor** sends resubmissions; the conformed models are already deduped to the final version.
  Use `fct_harbor__resubmissions` only for questions about resubmissions themselves.

## Models to avoid

- `legacy_finance_rollup` and `legacy_denials_2023` are deprecated and cover three of nine clients.
- `adhoc/` models (`denials_scratch_dan`, `quick_payer_check`, `tmp_charge_recon_JIRA2214`) are scratch work.
- `fct_claim_360` (`spider/`) is an unfinished stub; do not rely on it.
- `exec_revenue_report` mixes current and legacy numbers; quote it only when asked about that report.
- `denial_rate_summary` and `fct_org_denial_rate_by_payer` give the same denial rate at different
  grains; pick by grain.

## Which file to open

| Question | Open |
|---|---|
| Denial rate, denials by payer or client | `metrics/denials/denial-rate.yml`, then `fct_org_denial_rate_by_payer` or `denial_rate_summary` |
| Why claims were denied | `fct_org_denials_by_reason` |
| Charges, payments, collection rate by client | `fct_org_charges_by_client` |
| Trends over time | `fct_org_monthly_charges`, or `fct_org_claims` joined to `int_all__encounters` |
| Outstanding A/R | `fct_org_ar_summary` |
| Encounter mix, LOS | `fct_org_encounter_summary`, `fct_org_los_distribution` |
| Data quality by client | `fct_org_data_quality` |
| Procedure volume | `fct_org_procedure_volume` |
| Coding / unmatched diagnoses | `fct_org_coding_opportunities` |
