# Plot a DSM heatmap.

Displays the Design Structure Matrix as a heatmap where color intensity
represents the number of shared resources (parent) or risks
(grandparent) between task pairs.

## Usage

``` r
# S3 method for class 'dsm'
plot(x, main = NULL, col = NULL, ...)
```

## Arguments

- x:

  A `dsm` object returned by
  [`parent_dsm()`](https://paulgovan.github.io/PRA/reference/parent_dsm.md)
  or
  [`grandparent_dsm()`](https://paulgovan.github.io/PRA/reference/grandparent_dsm.md).

- main:

  Optional plot title. If `NULL`, a default title is generated.

- col:

  Color palette vector. If `NULL`, uses
  [`grDevices::heat.colors()`](https://rdrr.io/r/grDevices/palettes.html).

- ...:

  Additional arguments passed to
  [`graphics::image()`](https://rdrr.io/r/graphics/image.html).

## Value

Invisibly returns `x`.
