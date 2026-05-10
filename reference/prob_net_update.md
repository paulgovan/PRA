# Update a Probabilistic Network of Project Risks.

**Experimental.** This function is part of the experimental
probabilistic network module and the API may change in future versions.

## Usage

``` r
prob_net_update(
  graph,
  add_links = NULL,
  remove_links = NULL,
  update_distributions = NULL
)
```

## Arguments

- graph:

  An existing probabilistic network created by
  [`prob_net()`](https://paulgovan.github.io/PRA/reference/prob_net.md).

- add_links:

  Optional. A data frame with columns `source` and `target` to add new
  links.

- remove_links:

  Optional. A data frame with columns `source` and `target` to remove
  existing links.

- update_distributions:

  Optional. A named list of distributions to update. Format follows
  [`prob_net()`](https://paulgovan.github.io/PRA/reference/prob_net.md).

## Value

An updated `prob_net` object with modified links and/or distributions.

## Details

This function updates an existing probabilistic network by adding or
removing dependencies (edges) and updating probability distributions for
nodes.

## Examples

``` r
nodes <- data.frame(id = c("A", "B", "C"))
links <- data.frame(source = c("A", "B"), target = c("B", "C"))
distributions <- list(
 A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
 B = list(type = "normal", mean = 0, sd = 1),
 C = list(type = "uniform", min = 1, max = 5)
)
graph <- prob_net(nodes, links, distributions)
# Update the network
new_links <- data.frame(source = c("A"), target = c("C"))
updated_distributions <- list(
 B = list(type = "lognormal", meanlog = 0, sdlog = 0.5)
)
updated_graph <- prob_net_update(
 graph,
 add_links = new_links,
 update_distributions = updated_distributions
)
```
