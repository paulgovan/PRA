# Actual Cost (AC).

Calculates the Actual Cost (AC) of work completed based on the actual
costs incurred at each time period.

## Usage

``` r
ac(actual_costs, time_period, cumulative = TRUE)
```

## Arguments

- actual_costs:

  Vector of actual costs incurred at each time period. Can be either
  period costs (cost per period) or cumulative costs depending on the
  cumulative parameter.

- time_period:

  Current time period.

- cumulative:

  Logical. If TRUE (default), actual_costs are already cumulative and
  the value at time_period is returned directly. If FALSE, actual_costs
  are period costs and will be summed up to time_period.

## Value

The function returns the Actual Cost (AC) of work completed to date.

## See also

[`pv`](https://paulgovan.github.io/PRA/reference/pv.md),
[`ev`](https://paulgovan.github.io/PRA/reference/ev.md),
[`sv`](https://paulgovan.github.io/PRA/reference/sv.md),
[`cv`](https://paulgovan.github.io/PRA/reference/cv.md),
[`spi`](https://paulgovan.github.io/PRA/reference/spi.md),
[`cpi`](https://paulgovan.github.io/PRA/reference/cpi.md),
[`eac`](https://paulgovan.github.io/PRA/reference/eac.md)

## Examples

``` r
# Using cumulative costs (default)
cumulative_costs <- c(9000, 27000, 63000, 133000, 233000)
time_period <- 3
ac <- ac(cumulative_costs, time_period)
cat("Actual Cost (AC):", ac, "\n")
#> Actual Cost (AC): 63000 

# Using period costs
period_costs <- c(9000, 18000, 36000, 70000, 100000)
ac <- ac(period_costs, time_period, cumulative = FALSE)
cat("Actual Cost (AC):", ac, "\n")
#> Actual Cost (AC): 63000 
```
