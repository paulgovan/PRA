# Generate Correlation Matrix from Random Samples.

This function generates random samples from specified probability
distributions and computes the correlation matrix for the generated
samples.

## Usage

``` r
cor_matrix(num_samples = 100, num_vars = 5, dists)
```

## Arguments

- num_samples:

  The number of samples to generate.

- num_vars:

  The number of distributions to sample.

- dists:

  A list describing each distribution. Each element should be a function
  that generates random samples. The names of the list elements will be
  used to identify the distributions.

## Value

The function returns the correlation matrix for the distributions.

## References

Govan, Paul, and Ivan Damnjanovic. "The resource-based view on project
risk management." Journal of construction engineering and management
142.9 (2016): 04016034.

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
#> [1,]  1.00000000 -0.10967615 -0.09830084 -0.09427454 -0.12992432
#> [2,] -0.10967615  1.00000000 -0.09794341 -0.01927946 -0.02293894
#> [3,] -0.09830084 -0.09794341  1.00000000  0.02556913  0.13055368
#> [4,] -0.09427454 -0.01927946  0.02556913  1.00000000  0.10994306
#> [5,] -0.12992432 -0.02293894  0.13055368  0.10994306  1.00000000
```
