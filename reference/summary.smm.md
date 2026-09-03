# Summarize Second Moment Method results.

Summarizes the propagated moments and reports the percentiles implied by
a normal approximation.

## Usage

``` r
# S3 method for class 'smm'
summary(object, conf_level = 0.95, ...)
```

## Arguments

- object:

  An object of class `"smm"`.

- conf_level:

  Unused placeholder retained for symmetry; percentiles are fixed at
  P5/P50/P95.

- ...:

  Additional arguments (not used).

## Value

An object of class `"summary.smm"`, a list with components:

- total_mean, total_variance, total_sd:

  Propagated moments. Note the canonical names, which match those used
  by
  [`summary.mcs()`](https://paulgovan.github.io/PRA/reference/summary.mcs.md);
  the `smm` object itself carries `total_var` and `total_std`.

- cv:

  Coefficient of variation. `NA` when the mean is zero.

- percentiles:

  Named numeric vector of the P5, P50 and P95 percentiles implied by the
  normal approximation.

## Details

The Second Moment Method constrains only the first two moments of the
total, so the percentiles reported here are those of the normal
distribution with that mean and variance. This is the maximum-entropy
distribution consistent with what SMM computes, but it is an
approximation: durations and costs are non-negative while the normal is
not, so the lower percentiles are unreliable when `total_mean` is less
than roughly three standard deviations. Use
[`mcs()`](https://paulgovan.github.io/PRA/reference/mcs.md) when the
shape of the distribution matters.

## Examples

``` r
result <- smm(c(10, 15, 20), c(4, 9, 16))
summary(result)
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
