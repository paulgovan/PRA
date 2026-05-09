# Perform Inference on a Probabilistic Network of Project Risks.

This function performs inference on a probabilistic network of project
risks by simulating random samples from the distribution of each node.
The function supports normal, uniform, lognormal, discrete, conditional
distributions, and aggregate nodes that sum the values of specified
continuous nodes.

## Usage

``` r
prob_net_sim(network, num_samples = 1000)
```

## Arguments

- network:

  A prob_net object created by
  [`prob_net()`](https://paulgovan.github.io/PRA/reference/prob_net.md).

- num_samples:

  Number of samples to simulate for each node (default is 1000).

## Value

A data frame with `num_samples` rows and one column per node containing
the simulated samples.

## Details

Aggregate nodes are computed as the sum of values from the specified
continuous nodes. Conditional nodes depend on a discrete conditional
node; if the condition is true (value = 1), the node follows the
`true_dist`, otherwise it follows the `false_dist` (value = 0). For
discrete distributions, sampling is performed using
[`sample()`](https://rdrr.io/r/base/sample.html).

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
    false_dist = list(type = "lognormal", meanlog = 0, sdlog = 0.2)
  ),
  D = list(type = "aggregate", nodes = c("B", "C"))
)

# Create the network graph
graph <- prob_net(nodes, links, distributions = distributions)

# Perform inference (simulate 1000 samples)
simulation_results <- prob_net_sim(graph, num_samples = 1000)
head(simulation_results)
#>   A        B         C        D
#> 1 1 2.500190 1.4038386 3.904028
#> 2 0 1.712608 0.9651617 2.677770
#> 3 0 1.819046 0.7255989 2.544645
#> 4 1 2.849409 0.6168564 3.466266
#> 5 0 2.206482 1.0417206 3.248202
#> 6 0 2.344146 1.0655631 3.409709
```
