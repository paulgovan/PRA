# Generate Correlation Matrix.

Generate Correlation Matrix.

## Usage

``` r
cor_matrix(num_samples = 100, num_vars = 5, dists = dists)
```

## Arguments

- num_samples:

  The number of samples to generate.

- num_vars:

  The number of distributions to sample.

- dists:

  A list describing each distribution.

## Value

The function returns the correlation matrix for the distributions.

## Examples

``` r
# List of probability distributions
dists <- list(
  normal = function(n) rnorm(n, mean = 0, sd = 1),
  uniform = function(n) runif(n, min = 0, max = 1),
  exponential = function(n) rexp(n, rate = 1),
  poisson = function(n) rpois(n, lambda = 1),
  binomial = function(n) rbinom(n, size = 10, prob = 0.5)
)

# Generate correlation matrix
cor_matrix <- cor_matrix(num_samples = 100, num_vars = 5, dists = dists)

# Print correlation matrix
print(cor_matrix)
#>             [,1]        [,2]        [,3]        [,4]        [,5]
#> [1,]  1.00000000 -0.07276640  0.02422814 -0.06408570  0.00010258
#> [2,] -0.07276640  1.00000000 -0.11840276  0.03606379  0.08075921
#> [3,]  0.02422814 -0.11840276  1.00000000  0.11331743  0.01882768
#> [4,] -0.06408570  0.03606379  0.11331743  1.00000000 -0.02843640
#> [5,]  0.00010258  0.08075921  0.01882768 -0.02843640  1.00000000
```
