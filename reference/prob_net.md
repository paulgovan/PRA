# Probabilistic Network of Project Risks.

This function is part of the probabilistic network module, whose API may
still evolve in future versions.

## Usage

``` r
prob_net(nodes, links, distributions = NULL)
```

## Arguments

- nodes:

  A data frame containing the nodes of the graph. Must include a column
  `id` with unique identifiers for each node.

- links:

  A data frame containing the links of the graph. Must include columns
  `source` and `target` specifying the nodes that form each edge.

- distributions:

  A named list where names correspond to node IDs and values specify
  discrete probabilities, continuous probability distributions,
  conditional distributions, or aggregate distributions.

  - "discrete": Specifies `values` and `probs`.

  - "normal": Specifies `mean` and `sd`.

  - "lognormal": Specifies `meanlog` and `sdlog`.

  - "uniform": Specifies `min` and `max`.

  - "conditional": Specifies a `condition` (a discrete or conditional
    node) and two distributions (`true_dist`, `false_dist`). The
    conditional distributions can themselves be discrete or continuous.

  - "aggregate": Specifies `nodes` (a list of continuous node IDs to
    sum).

## Value

An S3 object of class `"prob_net"`: a list with

- `nodes`: The input `nodes` data frame.

- `links`: The input `links` data frame.

- `adjacency_matrix`: A directed matrix with a 1 in `[source, target]`
  for every edge.

- `distributions`: The input `distributions` list.

Objects of this class have
[`print.prob_net()`](https://paulgovan.github.io/PRA/reference/print.prob_net.md),
[`summary.prob_net()`](https://paulgovan.github.io/PRA/reference/summary.prob_net.md)
and
[`plot.prob_net()`](https://paulgovan.github.io/PRA/reference/plot.prob_net.md)
methods.

## Details

This function creates a probabilistic network graph representation of
project risks that supports discrete and continuous probability
distributions.

The links are load-bearing. A conditional node depends on its
`condition` and an aggregate node depends on every node it sums, and
`prob_net()` requires the edges in `links` to match that declared
structure exactly: an edge with no corresponding dependency, or a
dependency with no corresponding edge, is an error rather than a
silently ignored inconsistency. Nodes must additionally be supplied in a
topological order, with every link running from an earlier node to a
later one, which is the order
[`prob_net_sim()`](https://paulgovan.github.io/PRA/reference/prob_net_sim.md)
samples in and which also guarantees the graph is acyclic.

## Examples

``` r
nodes <- data.frame(id = c("A", "B", "C", "D"))
links <- data.frame(
  source = c("A", "B", "C"),
  target = c("B", "D", "D")
)
distributions <- list(
  A = list(type = "discrete", values = c(1, 0), probs = c(0.5, 0.5)),
  B = list(
    type = "conditional", condition = "A",
    true_dist  = list(type = "normal", mean = 1, sd = 0.5),
    false_dist = list(type = "lognormal", meanlog = -1, sdlog = 0.5)
  ),
  C = list(type = "uniform", min = 1, max = 5),
  D = list(type = "aggregate", nodes = c("B", "C"))
)
graph <- prob_net(nodes, links, distributions = distributions)
```
