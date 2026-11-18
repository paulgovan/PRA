# Plot a project schedule network.

Draws the activity-on-node network left to right, layered by longest
path from the start. Activities on the deterministic critical path (see
[`cpm()`](https://paulgovan.github.io/PRA/reference/cpm.md)) and the
links between them are drawn in red. Link types other than
finish-to-start, and non-zero lags, are labelled on the edge.

## Usage

``` r
# S3 method for class 'pra_schedule'
plot(x, main = NULL, node_cex = 3, label_cex = 0.7, ...)
```

## Arguments

- x:

  An object of class `"pra_schedule"`.

- main:

  Optional plot title.

- node_cex, label_cex:

  Node symbol and label sizes.

- ...:

  Additional arguments passed to
  [`graphics::plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Value

Invisibly returns `x`.

## Examples

``` r
proj <- project_schedule(
  data.frame(id = c("A", "B", "C", "D"), duration = c(3, 5, 4, 2)),
  data.frame(
    source = c("A", "A", "B", "C"), target = c("B", "C", "D", "D"),
    type = c("FS", "SS", "FS", "FS"), lag = c(0, 1, 0, 0)
  )
)
plot(proj)
```
