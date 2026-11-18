# Schedule Risk Analysis.

Monte Carlo schedule risk analysis of a resource-loaded project
schedule. Each iteration samples activity durations (from their
distributions, or from work and sampled resource productivity), samples
which discrete risk events occur and their impacts, and reschedules the
network with the critical path method (optionally resource-leveled; see
[`cpm()`](https://paulgovan.github.io/PRA/reference/cpm.md)). The result
describes the distribution of project finish and cost, how often and how
strongly each activity drives the finish, the impact of each risk, and
the uncertainty in the cost S-curve and resource usage over time.

## Usage

``` r
sra(x, num_sims = 10000, level = FALSE, keep_samples = FALSE, grid_n = 100)
```

## Arguments

- x:

  A `"pra_schedule"` object from
  [`project_schedule()`](https://paulgovan.github.io/PRA/reference/project_schedule.md).

- num_sims:

  Number of Monte Carlo iterations. Default 10000.

- level:

  Logical. Resource-level each iteration. Default `FALSE`.

- keep_samples:

  Logical. Keep the per-iteration duration, start, finish, criticality
  and risk-occurrence matrices. Default `FALSE`.

- grid_n:

  Number of time points for the cost S-curve and resource profiles.
  Default 100.

## Value

An S3 object of class `"sra"`, a list with:

- total_distribution:

  Simulated project finish, one per iteration.

- total_mean, total_sd:

  Mean and standard deviation of the finish.

- percentiles:

  P10, P50, P80 and P90 of the finish.

- cost_distribution:

  Simulated project cost, one per iteration.

- cost_percentiles:

  P10, P50, P80 and P90 of the cost.

- deterministic:

  The [`cpm()`](https://paulgovan.github.io/PRA/reference/cpm.md) result
  on baseline durations.

- prob_deterministic:

  Probability of finishing no later than the deterministic finish.

- activity_stats:

  Data frame of per-activity results: deterministic start and finish,
  mean and standard deviation of duration, mean and P10/P50/P90 start
  and finish, criticality index, duration sensitivity, cruciality and
  SSI.

- risk_stats:

  Data frame of per-risk results: probability, simulated occurrence
  rate, finish impact, cost impact and rank by finish impact. Zero rows
  when there are no risks.

- time_grid:

  Time points used for the curves below.

- cost_curve:

  Data frame of cumulative cost over `time_grid`: `mean`, `p10`, `p50`,
  `p90`.

- resource_profile:

  Named list, one data frame per resource, of usage over `time_grid`
  (`mean`, `p10`, `p50`, `p90`) with a `capacity` attribute.

- samples:

  When `keep_samples = TRUE`, a list of iteration x activity matrices
  `duration`, `start`, `finish`, `critical`, and the iteration x risk
  matrix `risk_occurred`; otherwise `NULL`.

- leveled, num_sims, project:

  Settings and the input schedule.

Objects of this class have
[`print.sra()`](https://paulgovan.github.io/PRA/reference/print.sra.md),
[`summary.sra()`](https://paulgovan.github.io/PRA/reference/summary.sra.md)
and
[`plot.sra()`](https://paulgovan.github.io/PRA/reference/plot.sra.md)
methods.

## Details

**Activity measures.**

- *Criticality index*: the proportion of iterations in which the
  activity is critical (zero total float, or on the driving path when
  leveled).

- *Duration sensitivity*: Spearman rank correlation between the
  activity's sampled duration and the project finish.

- *Cruciality index*: criticality index times duration sensitivity
  (Williams, 1992), which ranks activities by how much they actually
  move the finish date.

- *Schedule sensitivity index (SSI)*: criticality index times the ratio
  of the activity's duration standard deviation to the project finish
  standard deviation (PMI, 2009).

Measures based on duration spread are `NA` for activities whose duration
never varies.

**Risk measures.** For each risk, the mean finish (and cost) in
iterations where it occurred minus the mean in iterations where it did
not; `NA` when the risk always or never occurred.

**Merge bias.** Where paths converge, the finish is driven by the
longest of several uncertain paths, so the mean simulated finish usually
exceeds the deterministic finish even when every duration is symmetric.
This is why a network analysis differs from summing task durations with
[`mcs()`](https://paulgovan.github.io/PRA/reference/mcs.md).

**Time-phasing.** Each activity's cost (resource cost, fixed cost and
its share of risk costs) is spread linearly over its scheduled dates.
Resource usage is the sum of assigned units over the activities running
at each time. Both are evaluated on `grid_n` points from zero to the
latest simulated finish and summarized by their mean and P10, P50 and
P90.

**Performance.** Without leveling, the critical path passes are
vectorized across iterations and are fast. Leveling schedules every
iteration separately with a serial schedule-generation scheme whose cost
grows with the square of the number of activities, so large leveled
models may need fewer iterations.

The returned object carries `total_distribution`, so
[`contingency()`](https://paulgovan.github.io/PRA/reference/contingency.md)
applies directly to schedule contingency.

## References

Williams, Terry M. Criticality in stochastic networks. Journal of the
Operational Research Society 43.4 (1992): 353-357.

Project Management Institute. Practice Standard for Project Risk
Management. Newtown Square, PA: PMI, 2009.

Vanhoucke, Mario. Measuring time: Improving project performance using
earned value management. Springer, 2009.

## Examples

``` r
activities <- data.frame(id = c("A", "B", "C", "D"), duration = c(3, 5, 4, 2))
links <- data.frame(
  source = c("A", "A", "B", "C"),
  target = c("B", "C", "D", "D")
)
duration_dists <- list(
  B = list(type = "triangular", a = 4, b = 5, c = 9),
  C = list(type = "triangular", a = 3, b = 4, c = 8)
)
risks <- list(list(
  id = "Rework", prob = 0.2, activities = "D",
  impact = list(type = "uniform", min = 1, max = 2)
))
proj <- project_schedule(activities, links,
  duration_dists = duration_dists, risks = risks
)
set.seed(42)
res <- sra(proj, num_sims = 2000)
res
#> Schedule Risk Analysis 
#> Iterations: 2,000 
#> Deterministic finish: 10 periods (P10) 
#> Mean finish: 11.53 periods   SD: 1.189 
#> Finish percentiles:
#>    10%    50%    80%    90% 
#>  9.995 11.470 12.550 13.100 
#> Most critical activities:
#>  id criticality cruciality
#>   A       1.000         NA
#>   D       1.000      0.487
#>   B       0.728      0.521
#>   C       0.272      0.080
res$activity_stats[, c("id", "criticality", "cruciality")]
#>   id criticality cruciality
#> 1  A      1.0000         NA
#> 2  B      0.7275  0.5212753
#> 3  C      0.2725  0.0804491
#> 4  D      1.0000  0.4873088
contingency(res, phigh = 0.8, pbase = 0.5)
#>     80% 
#> 1.08829 
```
