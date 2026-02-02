# Print method for Sigmoidal Model

Displays the summary of the fitted sigmoidal model in a readable format.

## Usage

``` r
# S3 method for class 'nls'
print(x, ...)
```

## Arguments

- x:

  An object of class "nls" containing the fitted sigmoidal model
  results.

- ...:

  Additional arguments (not used).

## Value

No return value, called for side effects.

## Examples

``` r
# Set up a data frame of time and completion percentage data
data <- data.frame(time = 1:10, completion = c(5, 15, 40, 60, 70, 75, 80, 85
, 90, 95))

# Fit a logistic model to the data.
fit <- fit_sigmoidal(data, "time", "completion", "logistic")
# Print the model summary
print(fit)
#> Sigmoidal Model Fit Summary:
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
