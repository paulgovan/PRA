# Print a probabilistic network.

Displays the size and shape of the network: node and edge counts, how
many nodes are roots or terminal, the depth of the causal chain, and
which distribution types are in use.

## Usage

``` r
# S3 method for class 'prob_net'
print(x, ...)
```

## Arguments

- x:

  An object of class `"prob_net"` returned by
  [`prob_net()`](https://paulgovan.github.io/PRA/reference/prob_net.md)
  or
  [`prob_net_update()`](https://paulgovan.github.io/PRA/reference/prob_net_update.md).

- ...:

  Additional arguments (not used).

## Value

Invisibly returns `x`.

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
net <- prob_net(nodes, links, distributions = dists)
print(net)
#> Probabilistic Network of Project Risks
#> Nodes: 2   Edges: 1   Roots: 1   Terminal: 1   Depth: 2 layers
#> Node types: conditional (1), discrete (1)
#> Distributions: complete
#> Use summary() for per-node detail and plot() for the network graph.
```
