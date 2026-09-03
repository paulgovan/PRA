# Print a probabilistic network summary.

Print a probabilistic network summary.

## Usage

``` r
# S3 method for class 'summary.prob_net'
print(x, ...)
```

## Arguments

- x:

  An object of class `"summary.prob_net"` returned by
  [`summary.prob_net()`](https://paulgovan.github.io/PRA/reference/summary.prob_net.md).

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
print(summary(prob_net(nodes, links, distributions = dists)))
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
