# Update a Probabilistic Network of Project Risks.

This function updates an existing probabilistic network by adding or
removing dependencies (edges) and updating probability distributions for
nodes.

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

  An existing probabilistic network created by \`prob_net()\`.

- add_links:

  Optional. A data frame with columns \`source\` and \`target\` to add
  new links.

- remove_links:

  Optional. A data frame with columns \`source\` and \`target\` to
  remove existing links.

- update_distributions:

  Optional. A named list of distributions to update. Format follows
  \`prob_net()\`.

## Value

An updated \`prob_net\` object with modified links and/or distributions.
