# Summarize a sigmoidal model fit.

Extends the standard nonlinear least-squares summary with the sigmoidal
model type and the interpreted shape parameters.

## Usage

``` r
# S3 method for class 'pra_sigmoidal_fit'
summary(object, ...)
```

## Arguments

- object:

  An object of class `"pra_sigmoidal_fit"` returned by
  [`fit_sigmoidal()`](https://paulgovan.github.io/PRA/reference/fit_sigmoidal.md).

- ...:

  Additional arguments passed to
  [`stats::summary.nls()`](https://rdrr.io/r/stats/summary.nls.html).

## Value

An object of class `c("summary.pra_sigmoidal_fit", "summary.nls")`: the
standard `summary.nls` object with two additional components,
`model_type` (the sigmoidal family that was fitted) and `asymptote` (the
fitted upper bound, `K` for Pearl and Logistic models and `A` for
Gompertz). `model_type` is `NA` when the object did not come from
[`fit_sigmoidal()`](https://paulgovan.github.io/PRA/reference/fit_sigmoidal.md).

## Examples

``` r
data <- data.frame(time = 1:10, completion = c(
  5, 15, 40, 60, 70, 75, 80, 85, 90, 95
))
fit <- fit_sigmoidal(data, "time", "completion", "logistic")
summary(fit)
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
