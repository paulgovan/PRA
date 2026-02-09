# Posterior Cost Probability Density.

This function generates random samples from the posterior distribution
of the cost 'A' given observations of multiple risk events 'R_i'. Each
risk event has its own mean and standard deviation for the cost
distribution. The function also accounts for a baseline cost when no
risk event occurs.

## Usage

``` r
cost_post_pdf(
  num_sims,
  observed_risks,
  means_given_risks,
  sds_given_risks,
  base_cost = 0
)
```

## Arguments

- num_sims:

  Number of random samples to draw from the posterior distribution.

- observed_risks:

  A vector of observed values for each risk event 'R_i' (1 if observed,
  0 if not observed, NA if unobserved).

- means_given_risks:

  A vector of means of the normal distribution for cost 'A' given each
  risk event 'R_i'.

- sds_given_risks:

  A vector of standard deviations of the normal distribution for cost
  'A' given each risk event 'R_i'.

- base_cost:

  The baseline cost given no risk event occurs.

## Value

A numeric vector of random samples from the posterior distribution of
costs.

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for
engineering and construction project risk management. No. 172534. Cham,
Switzerland: Springer, 2020.

## Examples

``` r
# Example with three risk events
num_sims <- 1000
observed_risks <- c(1, NA, 1)
means_given_risks <- c(10000, 15000, 5000)
sds_given_risks <- c(2000, 1000, 1000)
base_cost <- 2000
posterior_samples <- cost_post_pdf(
  num_sims = num_sims,
  observed_risks = observed_risks,
  means_given_risks = means_given_risks,
  sds_given_risks = sds_given_risks,
  base_cost = base_cost
)
hist(posterior_samples, breaks = 30, col = "skyblue", main = "Posterior Cost PDF", xlab = "Cost")
```
