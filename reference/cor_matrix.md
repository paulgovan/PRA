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

  The number of distributions to sample. The first `num_vars` elements
  of `dists` are used.

- dists:

  A list describing each distribution. Each element should be a function
  that generates random samples. The names of the list elements are used
  to label the rows and columns of the result.

## Value

The function returns the correlation matrix for the distributions, with
rows and columns named after the distributions they were drawn from.
Because the columns are sampled independently, the off-diagonal entries
are sampling noise about zero: this generates correctly shaped,
positive-definite input for testing and for a near-independent baseline,
and is not an estimator of dependence between tasks.

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
#>                 normal     uniform exponential     poisson    binomial
#> normal      1.00000000  0.06473076  0.05224556  0.27937665  0.03459448
#> uniform     0.06473076  1.00000000  0.05646605 -0.05419664 -0.01709332
#> exponential 0.05224556  0.05646605  1.00000000 -0.17056880 -0.10869859
#> poisson     0.27937665 -0.05419664 -0.17056880  1.00000000  0.11908758
#> binomial    0.03459448 -0.01709332 -0.10869859  0.11908758  1.00000000
```
