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

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data Analytics for
Engineering and Construction Project Risk Management. Cham, Switzerland:
Springer, 2020.
[doi:10.1007/978-3-030-14251-3](https://doi.org/10.1007/978-3-030-14251-3)

## Examples

``` r
# Monte Carlo schedule risk (tasks treated as independent)
sim <- mcs(10000, building_project$task_distributions)
sim$percentiles
#>       5%      50%      95% 
#> 64.30804 71.60191 79.37655 

# Earned value snapshot at the current period
bp <- building_project
spi(ev(bp$bac, bp$actual_per_complete), pv(bp$bac, bp$schedule, bp$time_period))
#> [1] 0.8888889
```
