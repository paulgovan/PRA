# Summarize critical path method results.

Summarize critical path method results.

## Usage

``` r
# S3 method for class 'cpm'
summary(object, ...)
```

## Arguments

- object:

  An object of class `"cpm"`.

- ...:

  Additional arguments (not used).

## Value

An object of class `"summary.cpm"`, a list with the project finish,
deterministic cost, the critical path, the number of critical
activities, the number of near-critical activities (total float within
10% of the project duration), and the total and maximum float (`NA` when
leveled).

## Examples

``` r
proj <- project_schedule(
  data.frame(id = c("A", "B", "C"), duration = c(2, 3, 1)),
  data.frame(source = c("A", "A"), target = c("B", "C"))
)
summary(cpm(proj))
#> Critical Path Method Summary 
#> ----------------------------
#> Project finish: 5 periods 
#> Deterministic cost: 0 
#> Critical activities: 2 of 3 
#> Near-critical activities (float <= 10% of duration): 0 
#> Maximum total float: 2 periods 
#> Critical path: A -> B 
```
