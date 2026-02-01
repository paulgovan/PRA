# Earned Value (EV).

Calculates the Earned Value (EV) of work completed based on the Budget
at Completion (BAC) and the actual work completion percentage.

## Usage

``` r
ev(bac, actual_per_complete)
```

## Arguments

- bac:

  Budget at Completion (BAC) (total planned budget).

- actual_per_complete:

  Actual work completion percentage.

## Value

The function returns the Earned Value (EV) of work completed.

## See also

[`pv`](https://paulgovan.github.io/PRA/reference/pv.md),
[`ac`](https://paulgovan.github.io/PRA/reference/ac.md),
[`sv`](https://paulgovan.github.io/PRA/reference/sv.md),
[`cv`](https://paulgovan.github.io/PRA/reference/cv.md),
[`spi`](https://paulgovan.github.io/PRA/reference/spi.md),
[`cpi`](https://paulgovan.github.io/PRA/reference/cpi.md),
[`eac`](https://paulgovan.github.io/PRA/reference/eac.md)

## Examples

``` r
# Set the BAC and actual % complete for a toy project.
bac <- 100000
actual_per_complete <- 0.35

# Calculate the EV and print the results.
ev <- ev(bac, actual_per_complete)
cat("Earned Value (EV):", ev, "\n")
#> Earned Value (EV): 35000 
```
