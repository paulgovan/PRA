# Cost Variance (CV).

Calculates the Cost Variance (CV) of work completed based on the Earned
Value (EV) and Actual Cost (AC).

## Usage

``` r
cv(ev, ac)
```

## Arguments

- ev:

  Earned Value.

- ac:

  Actual Cost.

## Value

The function returns the Cost Variance (CV) of work completed.

## See also

[`pv`](https://paulgovan.github.io/PRA/reference/pv.md),
[`ev`](https://paulgovan.github.io/PRA/reference/ev.md),
[`ac`](https://paulgovan.github.io/PRA/reference/ac.md),
[`sv`](https://paulgovan.github.io/PRA/reference/sv.md),
[`spi`](https://paulgovan.github.io/PRA/reference/spi.md),
[`cpi`](https://paulgovan.github.io/PRA/reference/cpi.md),
[`eac`](https://paulgovan.github.io/PRA/reference/eac.md)

## Examples

``` r
# Set the BAC and actual % complete for an example project.
bac <- 100000
actual_per_complete <- 0.35

# Calcualte the EV
ev <- ev(bac, actual_per_complete)

# Set the actual costs and current time period and calculate the AC.
actual_costs <- c(9000, 18000, 36000, 70000, 100000)
time_period <- 3
ac <- ac(actual_costs, time_period)

# Calculate the CV and print the results.
cv <- cv(ev, ac)
cat("Cost Variance (CV):", cv, "\n")
#> Cost Variance (CV): -1000 
```
