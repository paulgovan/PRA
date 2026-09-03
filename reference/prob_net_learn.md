# Perform Bayesian Learning on a Probabilistic Network of Project Risks.

This function is part of the probabilistic network module, whose API may
still evolve in future versions.

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

Conditioning is performed by rejection sampling: the network is
simulated forward from its priors (as in
[`prob_net_sim()`](https://paulgovan.github.io/PRA/reference/prob_net_sim.md))
and only the draws whose observed nodes equal the supplied values are
retained, repeating until `num_samples` matching draws are collected.
Because whole joint draws are filtered, evidence propagates to
*upstream* (parent and confounding) nodes as well as downstream ones.
This distinguishes observational conditioning ("seeing", the sense of
\[Pearl 2009\]) from intervention ("doing"): only when the observed node
is a root cause with no shared ancestry do `prob_net_learn()` and
[`prob_net_update()`](https://paulgovan.github.io/PRA/reference/prob_net_update.md)
induce the same distribution.

Because matches are exact, observations are supported on discrete (or
discrete-conditional) nodes; observing a continuous node has probability
zero of an exact match and will raise an error. Nodes not listed in
`observations` retain their model distributions. If `observations` is
empty the result is a plain forward simulation.

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
  source = c("A", "B", "C"),
  target = c("C", "D", "D"),
  weight = c(1, 2, 3),
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
#> 1 1 2.429225 0.4910396 2.920265
#> 2 1 1.254075 1.0101766 2.264252
#> 3 1 1.461305 0.1216377 1.582942
#> 4 1 2.424495 1.1902248 3.614720
#> 5 1 2.538347 1.3652248 3.903572
#> 6 1 1.898325 0.6298804 2.528205
```
