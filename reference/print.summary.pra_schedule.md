# Print a project schedule summary.

Print a project schedule summary.

## Usage

``` r
# S3 method for class 'summary.pra_schedule'
print(x, ...)
```

## Arguments

- x:

  An object of class `"summary.pra_schedule"`.

- ...:

  Additional arguments (not used).

## Value

Invisibly returns `x`.

## Examples

``` r
proj <- project_schedule(
  data.frame(id = c("A", "B"), duration = c(2, 3)),
  data.frame(source = "A", target = "B")
)
print(summary(proj))
#> Project Schedule Summary
#> ------------------------
#> Activities: 2  (fixed: 2  distribution: 0  resource-driven: 0 )
#> Links: 1  ( FS: 1  SS: 0  FF: 0  SF: 0 )
#> Resources: 0  (capacity-limited: 0 )
#> Risk events: 0 
#> Start activities: A 
#> End activities: B 
#> Deterministic finish: 5 periods 
#> Deterministic cost: 0 
```
