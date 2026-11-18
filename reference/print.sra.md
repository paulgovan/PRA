# Print schedule risk analysis results.

Print schedule risk analysis results.

## Usage

``` r
# S3 method for class 'sra'
print(x, ...)
```

## Arguments

- x:

  An object of class `"sra"`.

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
print(sra(proj, num_sims = 500))
#> Schedule Risk Analysis 
#> Iterations: 500 
#> Deterministic finish: 5 periods (P27) 
#> Mean finish: 5.634 periods   SD: 0.8294 
#> Finish percentiles:
#>   10%   50%   80%   90% 
#> 4.640 5.526 6.383 6.859 
#> Most critical activities:
#>  id criticality cruciality
#>   A           1         NA
#>   B           1          1
```
