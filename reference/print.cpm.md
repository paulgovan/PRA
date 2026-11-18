# Print critical path method results.

Print critical path method results.

## Usage

``` r
# S3 method for class 'cpm'
print(x, digits = 4, ...)
```

## Arguments

- x:

  An object of class `"cpm"`.

- digits:

  Number of significant digits for dates. Default 4.

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
print(cpm(proj))
#> Critical Path Method 
#> Project finish: 5 periods 
#> Critical path: A -> B 
#> 
#>  id duration ES EF LS LF total_float free_float critical
#>   A        2  0  2  0  2           0          0     TRUE
#>   B        3  2  5  2  5           0          0     TRUE
#>   C        1  2  3  4  5           2          2    FALSE
```
