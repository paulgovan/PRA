# Print method for Monte Carlo Simulation results.

Displays the total mean, variance, standard deviation, and percentiles
of the Monte Carlo Simulation results in a readable format.

## Usage

``` r
# S3 method for class 'mcs'
print(x, ...)
```

## Arguments

- x:

  An object of class "mcs".

- ...:

  Additional arguments (not used).

## Value

None. Prints the results to the console.

## Examples

``` r
# Set the number of simulations and task distributions for a toy project.
num_sims <- 10000
task_dists <- list(
  list(type = "normal", mean = 10, sd = 2), # Task A: Normal distribution
  list(type = "triangular", a = 5, b = 10, c = 15), # Task B: Triangular distribution
  list(type = "uniform", min = 8, max = 12) # Task C: Uniform distribution
)

# Set the correlation matrix for the correlations between tasks.
cor_mat <- matrix(c(
  1, 0.5, 0.3,
  0.5, 1, 0.4,
  0.3, 0.4, 1
), nrow = 3, byrow = TRUE)

# Run the Monte Carlo sumulation and print the results.
results <- mcs(num_sims, task_dists, cor_mat)
# print(results)
```
