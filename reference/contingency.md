# Contingency Calculation.

Contingency Calculation.

## Usage

``` r
contingency(sims, phigh = 0.95, pbase = 0.5)
```

## Arguments

- sims:

  List of results from a Monte Carlo simulation.

- phigh:

  Percentile level for contingency calculation. Default is 0.95.

- pbase:

  Base level for contingency calculation. Default is 0.5

## Value

The function returns the value of calculated contingency.

## Examples

``` r
# Set the number os simulations and the task distributions for a toy project.
num_sims <- 10000
task_dists <- list(
  list(type = "normal", mean = 10, sd = 2),  # Task A: Normal distribution
  list(type = "triangular", a = 5, b = 10, c = 15),  # Task B: Triangular distribution
  list(type = "uniform", min = 8, max = 12)  # Task C: Uniform distribution
)

# Set the correlation matrix for the correlations between tasks.
cor_mat <- matrix(c(
  1, 0.5, 0.3,
  0.5, 1, 0.4,
  0.3, 0.4, 1
), nrow = 3, byrow = TRUE)

# Run the Monte Carlo simulation.
results <- mcs(num_sims, task_dists, cor_mat)

# Calculate the contingency and print the results.
contingency <- contingency(results, phigh = 0.95, pbase = 0.50)
cat("Contingency based on 95th percentile and 50th percentile:", contingency)
#> Contingency based on 95th percentile and 50th percentile: 7.237666
```
