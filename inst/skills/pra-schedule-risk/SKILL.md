---
name: pra-schedule-risk
description: >
  Run critical path (CPM) and Monte Carlo schedule risk analysis on a project
  network with the PRA package. Use when a user has activities with
  precedence logic (finish-to-start, start-to-start, finish-to-finish,
  start-to-finish, lags), parallel paths, resources with limited capacity or
  cost rates, uncertain durations or productivity, or a risk register, and
  wants the finish-date range, the probability of meeting a date, the
  critical path, criticality indices or a cost S-curve.
---

# When to use

- The schedule has **logic between activities** (not just a list of tasks to
  add up). Use `sra_tool` instead of `mcs_tool`: summing durations ignores
  parallel paths and understates the finish (merge bias).
- The user asks "what's the critical path?", "how likely are we to finish by
  X?", "which activities drive the finish?", or "what does the crane
  shortage do to the schedule?".
- Resources are shared and limited (set `level` to `"true"`), or carry cost
  (give them a `rate`).
- A risk register lists discrete events with a probability and an impact on
  specific activities.

# MCP tools

- `cpm_tool(activities_json, links_json, resources_json, assignments_json,
  level, time_unit)`: the deterministic plan. Call it first to show the
  baseline finish and critical path.
- `sra_tool(num_sims, activities_json, links_json, resources_json,
  assignments_json, risks_json, cor_mat_json, level, time_unit)`: the
  Monte Carlo analysis. Use `num_sims = 10000` (about 2000 when leveling a
  large network).
- `contingency_tool(phigh, pbase)` after `sra_tool` gives the schedule
  reserve, for example P80 minus P50.

## Argument formats

Activities, with an optional duration distribution `dist`:

```json
[{"id":"A","name":"Design","duration":10,
  "dist":{"type":"triangular","a":8,"b":10,"c":15}},
 {"id":"B","duration":5},
 {"id":"C","duration":null,"fixed_cost":20000}]
```

Distribution types: `normal` {mean, sd}, `triangular` {a = min, b = most
likely, c = max}, `uniform` {min, max}, `pert` {a, b, c}. Without a `dist` an
activity's duration is fixed.

Links (`type` defaults to FS and `lag` to 0; negative lags are leads):

```json
[{"source":"A","target":"B"},
 {"source":"A","target":"C","type":"SS","lag":3},
 {"source":"B","target":"C","type":"FF","lag":1}]
```

Resources (`capacity: null` means unlimited; `rate` is cost per unit per time
unit; `productivity` is an optional multiplier distribution with a positive
minimum, triangular, uniform or pert):

```json
[{"id":"crew","capacity":2,"rate":1500,
  "productivity":{"type":"pert","a":0.8,"b":1,"c":1.1}}]
```

Assignments. Adding `work` makes the activity's duration
`work / (units * productivity)`, so its duration then comes from the resource
and the activity must not also have a `dist`:

```json
[{"activity":"C","resource":"crew","units":2,"work":24}]
```

Risks (one draw per iteration; the impact is added to every listed activity):

```json
[{"id":"Permit delay","prob":0.3,"activities":["A"],
  "impact":{"type":"triangular","a":2,"b":4,"c":8},
  "cost_impact":{"type":"uniform","min":10000,"max":30000}}]
```

`cor_mat_json` correlates the activities that have a `dist`, in the order
they appear in `activities_json`.

# Interpreting results

- **Deterministic finish and P(meet deterministic)**: how optimistic the plan
  is. A plan at P10 to P30 is common, and that is the point of the analysis.
- **P50 and P80 finish**: typical target and commitment dates. The gap is the
  schedule contingency.
- **Criticality index**: the share of iterations in which the activity is on
  the critical path.
- **Cruciality** (criticality × rank correlation with finish): how much the
  activity actually moves the finish. Rank mitigation by cruciality, not by
  criticality alone: an always-critical activity with a fixed duration has
  zero cruciality.
- **Risk finish impact**: mean finish when the risk occurs minus when it does
  not. Rank risk responses by it.
- **Leveled results** move activities to respect capacity. Compare leveled and
  unleveled finishes to show the cost of a resource constraint. Float is not
  reported when leveled.

# Caveats

- Time is in abstract units from a common start (label them with
  `time_unit`). Working calendars and date constraints are not modelled.
- Leveling uses one priority rule (smallest late start). It is a realistic
  heuristic, not an optimum.

# References

- AACE International Recommended Practice 57R-09, Integrated Cost and
  Schedule Risk Analysis Using Monte Carlo Simulation of a CPM Model.
- Williams, T. (1992). Criticality in stochastic networks. JORS 43(4).
- Kolisch, R. (1996). Serial and parallel resource-constrained project
  scheduling methods revisited. EJOR 90(2).
