# Summarize schedule risk analysis results.

Summarize schedule risk analysis results.

## Usage

``` r
# S3 method for class 'sra'
summary(object, ...)
```

## Arguments

- object:

  An object of class `"sra"`.

- ...:

  Additional arguments (not used).

## Value

An object of class `"summary.sra"`, a list with the finish and cost
distribution summaries (mean, standard deviation, coefficient of
variation and P5-P95 percentiles), the deterministic finish and cost and
the probability of meeting them, the activity table ordered by
cruciality, and the risk table ordered by rank.

## Examples

``` r
proj <- project_schedule(
  data.frame(id = c("A", "B"), duration = c(2, 3)),
  data.frame(source = "A", target = "B"),
  duration_dists = list(B = list(type = "triangular", a = 2, b = 3, c = 6))
)
summary(sra(proj, num_sims = 500))
#> Schedule Risk Analysis Summary 
#> ------------------------------
#> Iterations: 500 
#> 
#> Finish (periods)
#>   Deterministic: 5  (probability of meeting it: 25.4%) 
#>   Mean: 5.697   SD: 0.8627   CV: 0.1514 
#>    5%   10%   25%   50%   75%   80%   90%   95% 
#> 4.454 4.644 4.990 5.601 6.306 6.440 6.906 7.302 
#> 
#> Activities (by cruciality)
#>  id mean_duration mean_finish finish_p90 criticality sensitivity cruciality ssi
#>   B         3.697       5.697      6.906           1           1          1   1
#>   A         2.000       2.000      2.000           1          NA         NA  NA
```
