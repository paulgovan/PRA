# Critical Path Method.

Computes the deterministic schedule of a
[`project_schedule()`](https://paulgovan.github.io/PRA/reference/project_schedule.md)
from its baseline durations: early and late start and finish dates,
total and free float, and the critical path. All four
precedence-diagramming link types (FS, SS, FF, SF) and lags are
supported. With `level = TRUE` the schedule is resource-leveled against
the capacity of each capacity-limited resource.

## Usage

``` r
cpm(x, level = FALSE)
```

## Arguments

- x:

  A `"pra_schedule"` object from
  [`project_schedule()`](https://paulgovan.github.io/PRA/reference/project_schedule.md).

- level:

  Logical. Level resources against capacity. Default `FALSE`.

## Value

An S3 object of class `"cpm"`, a list with:

- activities:

  Data frame with one row per activity: `id`, `name`, `duration`, `ES`,
  `EF`, `LS`, `LF`, `total_float`, `free_float` and `critical`.

- finish:

  Project finish time.

- critical_path:

  Ids of critical activities in start order.

- cost:

  Deterministic project cost: resource cost plus fixed cost.

- leveled:

  Whether the schedule was resource-leveled.

- project:

  The input schedule.

Objects of this class have
[`print.cpm()`](https://paulgovan.github.io/PRA/reference/print.cpm.md),
[`summary.cpm()`](https://paulgovan.github.io/PRA/reference/summary.cpm.md)
and
[`plot.cpm()`](https://paulgovan.github.io/PRA/reference/plot.cpm.md)
methods.

## Details

**Forward pass.** Activities are visited in topological order. An
activity starts at the latest of time zero and the constraint of each
incoming link: `FS`: predecessor finish + lag; `SS`: predecessor start +
lag; `FF`: predecessor finish + lag - own duration; `SF`: predecessor
start + lag - own duration.

**Backward pass.** From the project finish (the latest early finish),
each activity's late finish is the earliest of the project finish and
the mirror constraint of each outgoing link. Total float is late start
minus early start, and an activity is critical when its total float is
zero (within a small numerical tolerance). Free float is the slack
before an activity delays any successor's early dates.

**Resource leveling.** With `level = TRUE` activities are scheduled by
the serial schedule-generation scheme (Kolisch, 1996): repeatedly take
the eligible activity with the smallest unconstrained late start and
place it at the earliest time that satisfies its links and keeps every
capacity-limited resource within capacity for the activity's whole
duration. Float is not meaningful once resources move dates, so late
dates and floats are `NA` and criticality is determined by tracing the
*driving path* backward from the project finish through binding links
and through resource hand-offs.

## References

Kelley, James E., and Morgan R. Walker. Critical-path planning and
scheduling. Papers presented at the December 1-3, 1959, Eastern Joint
IRE-AIEE-ACM Computer Conference (1959): 160-173.

Kolisch, Rainer. Serial and parallel resource-constrained project
scheduling methods revisited: Theory and computation. European Journal
of Operational Research 90.2 (1996): 320-333.

## Examples

``` r
activities <- data.frame(id = c("A", "B", "C", "D"), duration = c(3, 5, 4, 2))
links <- data.frame(
  source = c("A", "A", "B", "C"),
  target = c("B", "C", "D", "D")
)
sched <- cpm(project_schedule(activities, links))
sched
#> Critical Path Method 
#> Project finish: 10 periods 
#> Critical path: A -> B -> D 
#> 
#>  id duration ES EF LS LF total_float free_float critical
#>   A        3  0  3  0  3           0          0     TRUE
#>   B        5  3  8  3  8           0          0     TRUE
#>   C        4  3  7  4  8           1          1    FALSE
#>   D        2  8 10  8 10           0          0     TRUE
sched$critical_path
#> [1] "A" "B" "D"
```
