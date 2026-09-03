# Print a sigmoidal model fit summary.

Print a sigmoidal model fit summary.

## Usage

``` r
# S3 method for class 'summary.pra_sigmoidal_fit'
print(x, ...)
```

## Arguments

- x:

  An object of class `"summary.pra_sigmoidal_fit"` returned by
  [`summary.pra_sigmoidal_fit()`](https://paulgovan.github.io/PRA/reference/summary.pra_sigmoidal_fit.md).

- ...:

  Additional arguments passed to the `summary.nls` print method.

## Value

Invisibly returns `x`.

## Examples

``` r
data <- data.frame(time = 1:10, completion = c(
  5, 15, 40, 60, 70, 75, 80, 85, 90, 95
))
print(summary(fit_sigmoidal(data, "time", "completion", "logistic")))
#> Sigmoidal (Logistic) model fit
#> Fitted asymptote: 87.91587 
#> ------------------------------
#> 
#> Formula: y ~ logistic(x, K, r, t0)
#> 
#> Parameters:
#>    Estimate Std. Error t value Pr(>|t|)    
#> K   87.9159     2.8935  30.384 1.08e-08 ***
#> r    0.9189     0.1379   6.664 0.000287 ***
#> t0   3.3911     0.1824  18.592 3.23e-07 ***
#> ---
#> Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#> 
#> Residual standard error: 5.108 on 7 degrees of freedom
#> 
#> Number of iterations to convergence: 12 
#> Achieved convergence tolerance: 1.49e-08
#> 
```
