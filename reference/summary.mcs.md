# Summarize Monte Carlo Simulation results.

Summarizes the simulated total distribution with its moments,
coefficient of variation, range, and a seven-point percentile grid. The
grid is wider than the three percentiles carried on the `mcs` object
itself.

## Usage

``` r
# S3 method for class 'mcs'
summary(object, ...)
```

## Arguments

- object:

  An object of class `"mcs"`.

- ...:

  Additional arguments (not used).

## Value

An object of class `"summary.mcs"`, a list with components:

- num_sims:

  Number of simulation draws.

- total_mean, total_variance, total_sd:

  Moments of the simulated total.

- cv:

  Coefficient of variation, `total_sd / total_mean`. `NA` when the mean
  is zero.

- total_min, total_max:

  Range of the simulated total.

- percentiles:

  Named numeric vector of the P5, P10, P25, P50, P75, P90 and P95
  percentiles.

## Examples

``` r
task_dists <- list(
  list(type = "normal", mean = 10, sd = 2),
  list(type = "uniform", min = 8, max = 12)
)
results <- mcs(1000, task_dists)
summary(results)
#> Monte Carlo Simulation Summary
#> ------------------------------
#> Simulations: 1,000 
#> Total Mean: 19.88472 
#> Total Variance: 5.671525 
#> Total Standard Deviation: 2.381496 
#> Coefficient of Variation: 0.1198 
#> Range: 12.30946 to 26.89125 
#> 
#> Percentiles:
#>       5%      10%      25%      50%      75%      90%      95% 
#> 16.00391 16.78103 18.20001 19.97666 21.52969 22.98859 23.66670 
```
