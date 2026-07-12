---
name: pra-earned-value
description: >
  Measure project cost/schedule performance and forecast final outcomes with
  Earned Value Management using the PRA package. Use when a user provides a
  budget (BAC), a planned schedule curve, and actual costs/progress and wants
  SPI, CPI, variances, or an Estimate at Completion (EAC).
---

# When to use

The user has a Budget at Completion, a cumulative planned-value curve, current
progress, and actual costs, and wants performance indices or forecasts.

# MCP tool

`evm_analysis_tool(bac, schedule_json, time_period, actual_per_complete,
actual_costs_json, cumulative)` runs the complete ANSI/EIA-748 suite in one
call — do not chain the individual metrics manually.

- `bac`: Budget at Completion (total planned budget).
- `schedule_json`: JSON array of cumulative planned completion fractions, e.g.
  `[0.1, 0.2, 0.4, 0.7, 1.0]`.
- `time_period`: current period (1-based index into the schedule).
- `actual_per_complete`: actual percent complete as a decimal (e.g. `0.35`).
- `actual_costs_json`: JSON array of actual costs per period, e.g.
  `[10000, 22000, 37000]`.
- `cumulative`: `"true"` if the costs are already cumulative, else `"false"`.

# What it returns

- **Baseline**: PV = BAC × planned%, EV = BAC × actual%, AC.
- **Variances**: SV = EV − PV (schedule), CV = EV − AC (cost).
- **Indices**: SPI = EV / PV, CPI = EV / AC (>1 is favorable).
- **Forecasts (EAC)**:
  - Typical (CPI-based): `BAC / CPI` — current trend continues.
  - Atypical: `AC + (BAC − EV)` — current variance is a one-off.
  - Combined: `AC + (BAC − EV) / (CPI × SPI)` — schedule pressure affects cost.
- **ETC** = EAC − AC, **VAC** = BAC − EAC, **TCPI** = efficiency required on
  remaining work to hit the target.

# Warning thresholds

- CPI or SPI below ~0.9 signals a project in trouble.
- CPI rarely improves by more than ~10% after a project is 20% complete.
- TCPI substantially above 1.0 is an unrealistic recovery target.

# References

- ANSI/EIA-748 Earned Value Management Systems standard.
- DOE EVMS Interpretation Handbook (EVMSIH v2.0).
