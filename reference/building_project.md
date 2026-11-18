# Mid-Rise Commercial Building Construction Project

A realistic example project used to illustrate the full PRA workflow:
schedule/cost uncertainty, earned value management, Bayesian risk
inference, and dependency structure analysis. The project comprises six
work packages for a mid-rise commercial building. The structure and
parameter ranges are adapted from the illustrative construction-project
examples in Damnjanovic and Reinschmidt (2020), the reference text this
package operationalizes; the values are representative estimates for a
project of this type rather than proprietary data from a specific
project.

## Usage

``` r
building_project
```

## Format

A named list with the following components:

- task_names:

  Character vector of the six work-package names.

- task_distributions:

  List of six triangular duration distributions (weeks), each a list
  with `type = "triangular"` and `a` (optimistic/min), `b` (most
  likely/mode), and `c` (pessimistic/max). Suitable input to
  [`mcs()`](https://paulgovan.github.io/PRA/reference/mcs.md) and
  [`sensitivity()`](https://paulgovan.github.io/PRA/reference/sensitivity.md).

- cor_mat:

  6x6 correlation matrix among task durations.

- bac:

  Budget at completion (US dollars).

- schedule:

  Numeric vector of cumulative planned-value fractions.

- actual_costs:

  Numeric vector of per-period actual costs (US dollars).

- time_period:

  Integer current reporting period.

- actual_per_complete:

  Actual fraction of work complete.

- cause_names:

  Character vector of root-cause names for the schedule-delay risk
  event.

- cause_probs:

  Probabilities that each root cause is present.

- risks_given_causes:

  P(delay \| cause present) for each cause.

- risks_given_not_causes:

  P(delay \| cause absent) for each cause.

- observed_causes:

  Mid-project observation of each cause (1 = occurred, 0 = did not
  occur, `NA` = not yet assessed).

- resource_names:

  Character vector of the six shared resources.

- resource_task:

  Resource-task incidence matrix S (resources x tasks) for
  [`parent_dsm()`](https://paulgovan.github.io/PRA/reference/parent_dsm.md)
  and
  [`grandparent_dsm()`](https://paulgovan.github.io/PRA/reference/grandparent_dsm.md).

- risk_names:

  Character vector of the three structural risks.

- risk_resource:

  Risk-resource incidence matrix R (risks x resources) for
  [`grandparent_dsm()`](https://paulgovan.github.io/PRA/reference/grandparent_dsm.md).

- schedule_activities:

  Data frame of the six activities (ids `T1` to `T6`) for
  [`project_schedule()`](https://paulgovan.github.io/PRA/reference/project_schedule.md):
  `id`, `name`, baseline `duration` (weeks; `NA` for the work-driven
  fit-out) and `fixed_cost` (materials and lump sums, US dollars).

- schedule_links:

  Data frame of precedence links with overlapping logic: `source`,
  `target`, `type` (FS, SS or FF) and `lag` (weeks).

- duration_dists:

  Named list of the triangular duration distributions of `T1` to `T5`
  (the first five `task_distributions`). Pair with `cor_mat[1:5, 1:5]`
  for correlated durations.

- schedule_resources:

  Data frame of the six resources: `id`, `capacity` (crews or units) and
  `rate` (US dollars per unit per week).

- schedule_assignments:

  Data frame of resource assignments following `resource_task`:
  `activity`, `resource`, `units` and `work` (crew-weeks; only the
  fit-out is work-driven).

- productivity_dists:

  Named list with a PERT productivity multiplier for the finishing crew.

- risk_register:

  List of two discrete risk events (adverse weather and late design
  changes), each with a probability, affected activities, a duration
  impact and a cost impact distribution.

- start_date:

  Project start date, used to label schedule plots.

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data Analytics for
Engineering and Construction Project Risk Management. Cham, Switzerland:
Springer, 2020.
[doi:10.1007/978-3-030-14251-3](https://doi.org/10.1007/978-3-030-14251-3)

## Examples

``` r
# Critical path and schedule risk analysis of the resource-loaded schedule
bp <- building_project
proj <- project_schedule(bp$schedule_activities, bp$schedule_links,
  duration_dists = bp$duration_dists, resources = bp$schedule_resources,
  productivity_dists = bp$productivity_dists,
  assignments = bp$schedule_assignments, risks = bp$risk_register,
  cor_mat = bp$cor_mat[1:5, 1:5], start_date = bp$start_date,
  time_unit = "weeks"
)
cpm(proj)$critical_path
#> [1] "T1" "T2" "T3" "T4" "T6"
sra(proj, num_sims = 1000)$percentiles
#>      10%      50%      80%      90% 
#> 45.38255 50.65396 54.64562 56.78376 

# Monte Carlo schedule risk (tasks treated as independent)
sim <- mcs(10000, building_project$task_distributions)
sim$percentiles
#>       5%      50%      95% 
#> 64.26613 71.58226 79.16606 

# Earned value snapshot at the current period
bp <- building_project
spi(ev(bp$bac, bp$actual_per_complete), pv(bp$bac, bp$schedule, bp$time_period))
#> [1] 0.8888889
```
