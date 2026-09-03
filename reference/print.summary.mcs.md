# Print a Monte Carlo Simulation summary.

Print a Monte Carlo Simulation summary.

## Usage

``` r
# S3 method for class 'summary.mcs'
print(x, ...)
```

## Arguments

- x:

  An object of class `"summary.mcs"` returned by
  [`summary.mcs()`](https://paulgovan.github.io/PRA/reference/summary.mcs.md).

- ...:

  Additional arguments (not used).

## Value

Invisibly returns `x`.

## Examples

``` r
task_dists <- list(
  list(type = "normal", mean = 10, sd = 2),
  list(type = "uniform", min = 8, max = 12)
)
print(summary(mcs(1000, task_dists)))
#> Monte Carlo Simulation Summary
#> ------------------------------
#> Simulations: 1,000 
#> Total Mean: 19.95862 
#> Total Variance: 5.188629 
#> Total Standard Deviation: 2.277856 
#> Coefficient of Variation: 0.1141 
#> Range: 12.95618 to 26.46519 
#> 
#> Percentiles:
#>       5%      10%      25%      50%      75%      90%      95% 
#> 16.31677 16.98417 18.31969 20.00743 21.51995 22.79188 23.59632 
```
