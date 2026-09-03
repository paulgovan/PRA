# Plot Monte Carlo Simulation results.

Displays the simulated total distribution as a histogram, optionally
overlaid with the moment-matched normal density, and marks the P50 and
P95 percentiles.

## Usage

``` r
# S3 method for class 'mcs'
plot(
  x,
  main = NULL,
  col = NULL,
  breaks = 50,
  normal_fit = TRUE,
  xlab = NULL,
  ...
)
```

## Arguments

- x:

  An object of class `"mcs"`.

- main:

  Optional plot title. If `NULL`, a default title is generated.

- col:

  Fill color for the histogram bars. If `NULL`, uses the package
  palette.

- breaks:

  Number of histogram breaks, passed to
  [`graphics::hist()`](https://rdrr.io/r/graphics/hist.html).

- normal_fit:

  Logical. Overlay the normal density implied by the simulated mean and
  standard deviation. Skipped automatically when the standard deviation
  is zero or non-finite.

- xlab:

  Optional x-axis label.

- ...:

  Additional arguments passed to
  [`graphics::hist()`](https://rdrr.io/r/graphics/hist.html).

## Value

Invisibly returns `x`.

## Examples

``` r
task_dists <- list(
  list(type = "normal", mean = 10, sd = 2),
  list(type = "uniform", min = 8, max = 12)
)
plot(mcs(1000, task_dists))
```
