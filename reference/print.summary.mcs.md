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
#> Total Mean: 19.89822 
#> Total Variance: 5.037164 
#> Total Standard Deviation: 2.244363 
#> Coefficient of Variation: 0.1128 
#> Range: 11.77571 to 26.84498 
#> 
#> Percentiles:
#>       5%      10%      25%      50%      75%      90%      95% 
#> 16.04072 16.95998 18.36315 19.98181 21.42195 22.65234 23.61173 
```
