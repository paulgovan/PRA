# Print method for SMM results.

This function defines how to print the results of the Second Moment
Method (SMM) analysis. It formats the output to display the total mean,
variance, and standard deviation in a readable manner.

## Usage

``` r
# S3 method for class 'smm'
print(x, ...)
```

## Arguments

- x:

  An object of class "smm" containing the SMM results.

- ...:

  Additional arguments (not used).

## Examples

``` r
mean <- c(10, 15, 20)
var <- c(4, 9, 16)
cor_mat <- matrix(c(
  1, 0.5, 0.3,
  0.5, 1, 0.4,
  0.3, 0.4, 1
), nrow = 3, byrow = TRUE)
result <- smm(mean, var, cor_mat)
print(result)
#> Second Moment Method Results:
#> ------------------------------
#> Total Mean:  45 
#> Total Variance:  49.4 
#> Total Standard Deviation:  7.028513 

# Without correlation matrix (independent tasks)
result <- smm(mean, var)
print(result)
#> Second Moment Method Results:
#> ------------------------------
#> Total Mean:  45 
#> Total Variance:  29 
#> Total Standard Deviation:  5.385165 
```
