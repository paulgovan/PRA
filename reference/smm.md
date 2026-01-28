# Second Moment Analysis.

Second Moment Analysis.

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

  The correlation matrix (optional).

## Value

The function returns a list of the total mean, variance, and standard
deviation for the project.

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
#> $total_mean
#> [1] 45
#> 
#> $total_var
#> [1] 49.4
#> 
#> $total_std
#> [1] 7.028513
#> 
```
