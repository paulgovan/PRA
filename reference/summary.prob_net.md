# Summarize a probabilistic network.

Builds a per-node table describing the causal structure: each node's
layer in the network, its parents, and the distribution it carries.

## Usage

``` r
# S3 method for class 'prob_net'
summary(object, ...)
```

## Arguments

- object:

  An object of class `"prob_net"`.

- ...:

  Additional arguments (not used).

## Value

An object of class `"summary.prob_net"`, a list with components:

- n_nodes, n_edges, n_roots, n_terminals, depth:

  Structural counts. `depth` is the number of layers in the longest
  causal chain.

- type_counts:

  A table of distribution types in use, or `NULL`.

- missing_distributions:

  Character vector of node ids with no declared distribution.

- node_table:

  Data frame with one row per node, in topological order, with columns
  `id`, `label`, `group`, `layer`, `type`, `n_parents`, `parents` and
  `parameters`. `label` and `group` are present only when the nodes data
  frame carries them.

## Examples

``` r
nodes <- data.frame(id = c("Risk", "Task"), stringsAsFactors = FALSE)
links <- data.frame(source = "Risk", target = "Task", stringsAsFactors = FALSE)
dists <- list(
  Risk = list(type = "discrete", values = c(0, 1), probs = c(0.7, 0.3)),
  Task = list(
    type = "conditional", condition = "Risk",
    true_dist = list(type = "normal", mean = 20, sd = 4),
    false_dist = list(type = "normal", mean = 10, sd = 2)
  )
)
summary(prob_net(nodes, links, distributions = dists))
#> Probabilistic Network of Project Risks
#> ------------------------------
#> Nodes: 2   Edges: 1   Roots: 1   Terminal: 1   Depth: 2 layers
#> 
#> Nodes (in topological order):
#>    id layer        type n_parents parents
#>  Risk     1    discrete         0        
#>  Task     2 conditional         1    Risk
#>                                parameters
#>                    discrete{0:0.7, 1:0.3}
#>  if Risk then normal(mean = 20, sd = 4...
```
