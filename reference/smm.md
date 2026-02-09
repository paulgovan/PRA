# Second Moment Method Analysis.

This function performs the Second Moment Method (SMM) analysis to
estimate the total mean, variance, and standard deviation of a project
based on individual task means, variances, and an optional correlation
matrix.

## Usage

``` r
smm(mean, var, cor_mat = NULL)
```

## Arguments

- mean:

  The mean vector.

- var:

  The variance vector.

- cor_mat:

  The correlation matrix (optional). If not provided, tasks are assumed
  to be independent.

## Value

The function returns a list of the total mean, variance, and standard
deviation for the project.

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for
engineering and construction project risk management. No. 172534. Cham,
Switzerland: Springer, 2020.

## Examples

``` r
# Set the mean vector, variance vector, and correlation matrix for a toy project.
mean <- c(10, 15, 20)
var <- c(4, 9, 16)
cor_mat <- matrix(c(
  1, 0.5, 0.3,
  0.5, 1, 0.4,
  0.3, 0.4, 1
), nrow = 3, byrow = TRUE)

# Use the Second Moment Method to estimate the results for the project.
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

# When certain tasks are discrete and others are continuous, the SMM can still
# be applied as long as the variance values accurately reflect the variability of each task.

discrete_mean <- c(5, 10)
discrete_var <- c(0, 0)
continuous_mean <- c(15, 20)
continuous_var <- c(4, 5)
mean <- c(discrete_mean, continuous_mean)
var <- c(discrete_var, continuous_var)
cor_mat <- matrix(c(
  1, 0, 0.2, 0.3,
  0, 1, 0.1, 0.2,
  0.2, 0.1, 1, 0.4,
  0.3, 0.2, 0.4,
  1
), nrow = 4, byrow = TRUE)
result <- smm(mean, var, cor_mat)
print(result)
#> Second Moment Method Results:
#> ------------------------------
#> Total Mean:  50 
#> Total Variance:  12.57771 
#> Total Standard Deviation:  3.546507 
```
