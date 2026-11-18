# Print a project schedule.

Print a project schedule.

## Usage

``` r
# S3 method for class 'pra_schedule'
print(x, ...)
```

## Arguments

- x:

  An object of class `"pra_schedule"`.

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
print(proj)
#> Project Schedule
#> Activities: 2   Links: 1   Resources: 0   Risks: 0 
#> Time unit: periods
#> 
#>  id duration driver predecessors
#>   A        2  fixed             
#>   B        3  fixed            A
```
