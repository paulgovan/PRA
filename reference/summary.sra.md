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
cruciality, the risk table ordered by rank, and the risk-network node
table ordered by rank (`NULL` without a risk network).

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
#>   Deterministic: 5  (probability of meeting it: 22.2%) 
#>   Mean: 5.684   SD: 0.8382   CV: 0.1475 
#>    5%   10%   25%   50%   75%   80%   90%   95% 
#> 4.429 4.653 5.043 5.559 6.280 6.415 6.875 7.254 
#> 
#> Activities (by cruciality)
#>  id mean_duration mean_finish finish_p90 criticality sensitivity cruciality ssi
#>   B         3.684       5.684      6.875           1           1          1   1
#>   A         2.000       2.000      2.000           1          NA         NA  NA
```
