# Print a schedule risk analysis summary.

Print a schedule risk analysis summary.

## Usage

``` r
# S3 method for class 'summary.sra'
print(x, ...)
```

## Arguments

- x:

  An object of class `"summary.sra"`.

- ...:

  Additional arguments (not used).

## Value

Invisibly returns `x`.

## Examples

``` r
proj <- project_schedule(
  data.frame(id = c("A", "B"), duration = c(2, 3)),
  data.frame(source = "A", target = "B"),
  duration_dists = list(B = list(type = "triangular", a = 2, b = 3, c = 6))
)
print(summary(sra(proj, num_sims = 500)))
#> Schedule Risk Analysis Summary 
#> ------------------------------
#> Iterations: 500 
#> 
#> Finish (periods)
#>   Deterministic: 5  (probability of meeting it: 27.4%) 
#>   Mean: 5.618   SD: 0.8278   CV: 0.1473 
#>    5%   10%   25%   50%   75%   80%   90%   95% 
#> 4.398 4.548 4.951 5.581 6.150 6.346 6.764 7.132 
#> 
#> Activities (by cruciality)
#>  id mean_duration mean_finish finish_p90 criticality sensitivity cruciality ssi
#>   B         3.618       5.618      6.764           1           1          1   1
#>   A         2.000       2.000      2.000           1          NA         NA  NA
```
