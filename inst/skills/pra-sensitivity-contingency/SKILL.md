---
name: pra-sensitivity-contingency
description: >
  Size a project contingency reserve and rank the tasks that drive total
  uncertainty, using the PRA package. Use after (or alongside) a Monte Carlo
  simulation when a user asks "how much reserve do I need?" or "which tasks
  should I focus mitigation on?"
---

# Sensitivity analysis

`sensitivity_tool(task_dists_json, cor_mat_json)` measures each task's
contribution to total project variance. It takes the **same** input format as
`mcs_tool` (a JSON array of task distributions plus an optional correlation
matrix). Returns one value per task; higher values are the primary drivers of
overall uncertainty. Results are typically shown as a tornado chart. Direct
mitigation resources at the highest-sensitivity tasks first.

# Contingency reserve

`contingency_tool(phigh, pbase)` returns the buffer between a high-confidence
percentile and the base estimate:

```
contingency = P_high - P_base
```

- `phigh` (default `0.95`): high-confidence percentile — there is a `phigh`
  probability the actual value will not exceed it.
- `pbase` (default `0.50`): the median ("most likely") total.

**Important:** call `mcs_tool` first — `contingency_tool` operates on the most
recent Monte Carlo results.

# Common confidence levels

- **P80 contingency**: moderate confidence, common in commercial projects.
- **P95 contingency**: high confidence, common in government/defense projects.
- **Management reserve**: an additional buffer for unknown-unknowns, typically
  5–10% of BAC, held above contingency.

# Workflow

1. `mcs_tool(num_sims, task_dists_json, cor_mat_json)`
2. `contingency_tool(phigh = 0.95, pbase = 0.50)`
3. `sensitivity_tool(task_dists_json, cor_mat_json)`
4. Reduce uncertainty in high-sensitivity tasks to shrink the needed reserve.

# References

- GAO Cost Estimating and Assessment Guide (GAO-20-195G).
- GAO Schedule Assessment Guide (GAO-16-89G).
