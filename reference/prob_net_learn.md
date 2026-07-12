# Perform Bayesian Learning on a Probabilistic Network of Project Risks.

**Experimental.** This function is part of the experimental
probabilistic network module and the API may change in future versions.

## Usage

``` r
prob_net_learn(network, observations = list(), num_samples = 1000)
```

## Arguments

- network:

  A prob_net object created by
  [`prob_net()`](https://paulgovan.github.io/PRA/reference/prob_net.md).

- observations:

  A named list where names are node IDs and values are observed values.

- num_samples:

  Number of samples to simulate for each node (default is 1000).

## Value

A data frame with `num_samples` rows and one column per node containing
the simulated posterior samples.

## Details

This function updates a probabilistic network of project risks with
observed values for certain nodes and then performs inference to
generate posterior distributions for unobserved nodes. The function
supports normal, uniform, lognormal, conditional continuous, conditional
discrete, discrete, and aggregate (summation) node types.

Normal nodes are sampled from a normal distribution using the specified
mean and sd. Uniform nodes are sampled from a uniform distribution
between the specified min and max values. Lognormal nodes are sampled
from a lognormal distribution with specified meanlog and sdlog.
Conditional nodes depend on a discrete conditional node; if the
condition is TRUE (value = 1), the node follows the `true_dist`,
otherwise it follows the `false_dist` (value = 0). Conditional
distributions can be normal, lognormal, uniform, or discrete. Discrete
nodes are sampled using
[`sample()`](https://rdrr.io/r/base/sample.html), and aggregate nodes
are computed as the sum of values from the specified nodes. Observed
nodes are fixed at their given values.

## Examples

``` r
# Define nodes
nodes <- data.frame(
  id = c("A", "B", "C", "D"),
  label = c("Node A", "Node B", "Node C", "Node D"),
  stringsAsFactors = FALSE
)

# Define links
links <- data.frame(
  source = c("A", "A", "B", "C"),
  target = c("B", "C", "D", "D"),
  weight = c(1, 2, 3, 4),
  stringsAsFactors = FALSE
)

# Define distributions for nodes
distributions <- list(
  A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
  B = list(type = "normal", mean = 2, sd = 0.5),
  C = list(
    type = "conditional", condition = "A",
    true_dist = list(type = "normal", mean = 1, sd = 0.5),
    false_dist = list(type = "discrete", values = c(0, 1), probs = c(0.4, 0.6))
  ),
  D = list(type = "aggregate", nodes = c("B", "C"))
)

# Create the network graph
graph <- prob_net(nodes, links, distributions = distributions)

# Perform Bayesian updating with observations
observations <- list(A = 1)
updated_results <- prob_net_learn(graph, observations, num_samples = 1000)
head(updated_results)
#>   A        B         C        D
#> 1 1 1.367026 1.1991160 2.566142
#> 2 1 1.547887 1.7156286 3.263515
#> 3 1 2.615949 1.1159436 3.731892
#> 4 1 1.908410 1.0086158 2.917026
#> 5 1 2.306369 0.7454623 3.051831
#> 6 1 1.833783 0.7003983 2.534182
```
