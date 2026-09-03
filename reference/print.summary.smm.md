# Print a Second Moment Method summary.

Print a Second Moment Method summary.

## Usage

``` r
# S3 method for class 'summary.smm'
print(x, ...)
```

## Arguments

- x:

  An object of class `"summary.smm"` returned by
  [`summary.smm()`](https://paulgovan.github.io/PRA/reference/summary.smm.md).

- ...:

  Additional arguments (not used).

## Value

Invisibly returns `x`.

## Examples

``` r
print(summary(smm(c(10, 15, 20), c(4, 9, 16))))
#> Second Moment Method Summary
#> ------------------------------
#> Total Mean:  45 
#> Total Variance:  29 
#> Total Standard Deviation:  5.385165 
#> Coefficient of Variation:  0.1197 
#> 
#> Percentiles (normal approximation):
#>       5%      50%      95% 
#> 36.14219 45.00000 53.85781 
```
