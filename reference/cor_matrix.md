# Generate Correlation Matrix from Random Samples.

This function generates random samples from specified probability
distributions and computes the correlation matrix for the generated
samples.

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

  A list describing each distribution. Each element should be a function
  that generates random samples. The names of the list elements will be
  used to identify the distributions.

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
#> [1,]  1.00000000 -0.03690034 -0.07459820  0.16084884 -0.06662177
#> [2,] -0.03690034  1.00000000 -0.01642801 -0.10972562 -0.02762785
#> [3,] -0.07459820 -0.01642801  1.00000000 -0.09137076 -0.14507929
#> [4,]  0.16084884 -0.10972562 -0.09137076  1.00000000 -0.11794046
#> [5,] -0.06662177 -0.02762785 -0.14507929 -0.11794046  1.00000000
```
