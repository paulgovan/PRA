# Build a Project Schedule for Critical Path and Schedule Risk Analysis.

Assembles and validates a resource-loaded project schedule: activities,
precedence links, duration uncertainty, resources with capacities and
cost rates, resource assignments, and a register of discrete risk
events. The result is the input to
[`cpm()`](https://paulgovan.github.io/PRA/reference/cpm.md)
(deterministic critical path method) and
[`sra()`](https://paulgovan.github.io/PRA/reference/sra.md) (Monte Carlo
schedule risk analysis).

## Usage

``` r
project_schedule(
  activities,
  links = NULL,
  duration_dists = NULL,
  resources = NULL,
  productivity_dists = NULL,
  assignments = NULL,
  risks = NULL,
  cor_mat = NULL,
  start_date = NULL,
  time_unit = "periods"
)
```

## Arguments

- activities:

  A data frame with one row per activity and columns `id` (required,
  unique), `name` (optional label, defaults to `id`), `duration`
  (non-negative baseline duration; may be `NA` for activities whose
  duration comes from a distribution or work assignments) and
  `fixed_cost` (optional non-resource cost, default 0).

- links:

  A data frame of precedence links with columns `source` and `target`
  (activity ids), and optional `type` (`"FS"`, `"SS"`, `"FF"` or `"SF"`,
  case-insensitive, default `"FS"`) and `lag` (default 0). `NULL` for a
  schedule without links.

- duration_dists:

  Optional named list of duration distributions, named by activity id.

- resources:

  Optional data frame with columns `id` (required), `capacity` (positive
  units available, `NA` = unconstrained, default `NA`) and `rate`
  (non-negative cost per unit per time unit, default 0).

- productivity_dists:

  Optional named list of productivity multiplier distributions, named by
  resource id. A draw of 0.8 makes that resource's work-driven
  activities take 1 / 0.8 = 1.25 times longer.

- assignments:

  Optional data frame with columns `activity`, `resource`, `units`
  (positive units used per time unit while the activity runs) and
  optional `work` (positive total work; `NA` for an assignment that does
  not drive duration).

- risks:

  Optional list of risk events; see Details.

- cor_mat:

  Optional correlation matrix among the activities in `duration_dists`,
  in the order of `names(duration_dists)` or with matching dimnames.
  Must be positive definite. Induced by a Gaussian copula, as in
  [`mcs()`](https://paulgovan.github.io/PRA/reference/mcs.md).

- start_date:

  Optional project start `Date` (or a string coercible by
  [`as.Date()`](https://rdrr.io/r/base/as.Date.html)) used to label plot
  axes. Time is otherwise measured in abstract `time_unit`s from zero;
  calendars are not modelled.

- time_unit:

  Character label for the time unit, such as `"days"` or `"weeks"`. Used
  for labels only.

## Value

An S3 object of class `"pra_schedule"`: a list holding the validated and
normalized inputs together with the topological order and adjacency
matrix of the activity network. Objects of this class have
[`print.pra_schedule()`](https://paulgovan.github.io/PRA/reference/print.pra_schedule.md),
[`summary.pra_schedule()`](https://paulgovan.github.io/PRA/reference/summary.pra_schedule.md)
and
[`plot.pra_schedule()`](https://paulgovan.github.io/PRA/reference/plot.pra_schedule.md)
methods.

## Details

**Durations.** Every activity needs exactly one duration source:

- a fixed `duration` in `activities`;

- an entry in `duration_dists` (its `duration`, if also given, is used
  as the deterministic baseline; otherwise the baseline is the mode of a
  triangular or PERT distribution, or the mean of a normal or uniform
  one);

- work assignments (`work` in `assignments`), in which case the activity
  is *resource-driven*: its duration is the longest of
  `work / (units * productivity)` across its work assignments, with
  productivity 1 in the deterministic baseline. A resource-driven
  activity cannot also have a duration distribution; uncertainty enters
  through `productivity_dists`.

**Links.** Precedence links use the precedence diagramming method: `FS`
(finish-to-start), `SS` (start-to-start), `FF` (finish-to-finish) and
`SF` (start-to-finish), each with a `lag` in time units, which may be
negative (a lead). Links must form a directed acyclic graph; a cycle is
an error that names the activities on it.

**Resources.** A resource with a finite `capacity` is capacity-limited
and is respected when scheduling with `level = TRUE` in
[`cpm()`](https://paulgovan.github.io/PRA/reference/cpm.md) or
[`sra()`](https://paulgovan.github.io/PRA/reference/sra.md); a capacity
of `NA` means unconstrained. `rate` is cost per unit of resource per
time unit, so an assignment costs `units * rate * duration`. No single
assignment may need more units than its resource's capacity.

**Risks.** Each risk is a list with `id`, `prob` (probability of
occurring in an iteration), `activities` (ids it affects), `impact` (a
distribution of time added to each affected activity's duration when the
risk occurs) and optionally `cost_impact` (a distribution of cost added
when it occurs, shared equally among the affected activities for
time-phasing).

**Distributions.** Distribution specifications use the same format as
[`mcs()`](https://paulgovan.github.io/PRA/reference/mcs.md): a list with
a `type` of `"normal"` (`mean`, `sd`), `"triangular"` (`a` = min, `b` =
mode, `c` = max), `"uniform"` (`min`, `max`) or `"pert"` (`a`, `b`, `c`,
the Beta-PERT distribution). Sampled durations are truncated at zero.
Productivity multipliers must use a bounded type (triangular, uniform or
PERT) with a positive minimum.

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for
engineering and construction project risk management. Cham, Switzerland:
Springer, 2020.

Kolisch, Rainer. Serial and parallel resource-constrained project
scheduling methods revisited: Theory and computation. European Journal
of Operational Research 90.2 (1996): 320-333.

## Examples

``` r
activities <- data.frame(
  id = c("A", "B", "C", "D"),
  duration = c(3, 5, 4, 2)
)
links <- data.frame(
  source = c("A", "A", "B", "C"),
  target = c("B", "C", "D", "D"),
  type = c("FS", "SS", "FS", "FF"),
  lag = c(0, 1, 0, 1)
)
duration_dists <- list(
  B = list(type = "triangular", a = 4, b = 5, c = 9),
  C = list(type = "pert", a = 3, b = 4, c = 7)
)
resources <- data.frame(id = "crew", capacity = 1, rate = 1000)
assignments <- data.frame(
  activity = c("B", "C"), resource = "crew", units = 1
)
risks <- list(
  list(
    id = "Late permit", prob = 0.3, activities = "A",
    impact = list(type = "uniform", min = 1, max = 3)
  )
)
proj <- project_schedule(activities, links,
  duration_dists = duration_dists, resources = resources,
  assignments = assignments, risks = risks, time_unit = "days"
)
proj
#> Project Schedule
#> Activities: 4   Links: 4   Resources: 1   Risks: 1 
#> Time unit: days
#> 
#>  id duration       driver predecessors
#>   A        3        fixed             
#>   B        5 distribution            A
#>   C        4 distribution        ASS+1
#>   D        2        fixed     B, CFF+1
```
