# Plot critical path method results.

Plot critical path method results.

## Usage

``` r
# S3 method for class 'cpm'
plot(x, type = c("gantt", "network"), main = NULL, ...)
```

## Arguments

- x:

  An object of class `"cpm"`.

- type:

  `"gantt"` (default) for a Gantt chart with critical activities in red
  and total float as a grey bar, or `"network"` for the activity-on-node
  network with the critical path highlighted.

- main:

  Optional plot title.

- ...:

  Additional arguments passed to
  [`graphics::plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Value

Invisibly returns `x`.

## Examples

``` r
proj <- project_schedule(
  data.frame(id = c("A", "B", "C", "D"), duration = c(3, 5, 4, 2)),
  data.frame(source = c("A", "A", "B", "C"), target = c("B", "C", "D", "D"))
)
res <- cpm(proj)
plot(res)

plot(res, type = "network")
```
