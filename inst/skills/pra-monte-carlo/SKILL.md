---
name: pra-monte-carlo
description: >
  Run Monte Carlo (or fast Second Moment) schedule/cost risk simulations with
  the PRA package. Use when a user provides task-level uncertainty
  distributions and needs the range of possible project outcomes — mean,
  standard deviation, and P5/P50/P95 percentiles — optionally accounting for
  task correlation.
---

# When to use

- Task-level uncertainty can be described with probability distributions.
- The user needs percentile-based estimates (P50, P80, P95) for budgeting or
  scheduling, or a confidence level for a cost/schedule target.
- Tasks may be correlated and you need to capture joint uncertainty.

If only first and second moments (means and variances) are available, or a
rapid analytical estimate is enough, use the Second Moment Method instead.

# MCP tools

- `mcs_tool(num_sims, task_dists_json, cor_mat_json)` — full Monte Carlo
  simulation. `num_sims` is typically `10000`.
- `smm_tool(mean_json, var_json, cor_mat_json)` — fast analytical estimate of
  total mean and variance from task means and variances.

`task_dists_json` is a JSON array of task distribution objects:

```json
[{"type":"normal","mean":10,"sd":2},
 {"type":"triangular","a":5,"b":10,"c":15},
 {"type":"uniform","min":8,"max":12}]
```

- **normal**: `mean`, `sd`
- **triangular**: `a` (min), `b` (max), `c` (mode) — most common in practice
- **uniform**: `min`, `max`

`cor_mat_json` is an optional JSON 2-D array; use `"null"` (or omit) for
independent tasks. Ignoring positive correlation underestimates total variance.

# Interpreting results

- **P50 (median)**: value with a 50% chance of being exceeded.
- **P80**: common contingency-budgeting threshold.
- **P95**: high-confidence estimate for management reserve / worst case.
- **Mean** may differ from P50 for skewed distributions.

Use at least 10,000 simulations for stable tail percentiles.

# Follow-ups

- `contingency_tool` for a reserve buffer (skill: `pra-sensitivity-contingency`).
- `sensitivity_tool` to find the dominant risk drivers.

# References

- GAO Cost Estimating and Assessment Guide (GAO-20-195G), Ch. 12.
- RAND, Quantitative Risk Analysis for Project Management (WR-112).
