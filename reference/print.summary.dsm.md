# Print a DSM summary.

Print a DSM summary.

## Usage

``` r
# S3 method for class 'summary.dsm'
print(x, ...)
```

## Arguments

- x:

  An object of class `"summary.dsm"` returned by
  [`summary.dsm()`](https://paulgovan.github.io/PRA/reference/summary.dsm.md).

- ...:

  Additional arguments (not used).

## Value

Invisibly returns `x`.

## Examples

``` r
S <- matrix(c(
  1, 1, 0,
  0, 1, 1
), nrow = 2, byrow = TRUE)
colnames(S) <- c("Design", "Build", "Test")
print(summary(parent_dsm(S)))
#> Resource-based 'Parent' Design Structure Matrix
#> ------------------------------
#> Tasks: 3  Resources: 2
#> Coupling density: 0.667 
#> Total shared dependencies: 2 
#> 
#> Coupling by task:
#> Design  Build   Test 
#>      1      2      1 
#> 
#> Most coupled task pairs (shared resources):
#>  task_a task_b shared
#>  Design  Build      1
#>   Build   Test      1
```
