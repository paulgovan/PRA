# Print a critical path method summary.

Print a critical path method summary.

## Usage

``` r
# S3 method for class 'summary.cpm'
print(x, ...)
```

## Arguments

- x:

  An object of class `"summary.cpm"`.

- ...:

  Additional arguments (not used).

## Value

Invisibly returns `x`.

## Examples

``` r
proj <- project_schedule(
  data.frame(id = c("A", "B", "C"), duration = c(2, 3, 1)),
  data.frame(source = c("A", "A"), target = c("B", "C"))
)
print(summary(cpm(proj)))
#> Critical Path Method Summary 
#> ----------------------------
#> Project finish: 5 periods 
#> Deterministic cost: 0 
#> Critical activities: 2 of 3 
#> Near-critical activities (float <= 10% of duration): 0 
#> Maximum total float: 2 periods 
#> Critical path: A -> B 
```
