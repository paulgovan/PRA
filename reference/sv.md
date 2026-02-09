# Schedule Variance (SV).

Calculates the Schedule Variance (SV) of work completed based on the
Earned Value (EV) and Planned Value (PV).

## Usage

``` r
sv(ev, pv)
```

## Arguments

- ev:

  Earned Value.

- pv:

  Planned Value.

## Value

The function returns the Schedule Variance (SV) of work completed.

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for
engineering and construction project risk management. No. 172534. Cham,
Switzerland: Springer, 2020.

## See also

[`pv`](https://paulgovan.github.io/PRA/reference/pv.md),
[`ev`](https://paulgovan.github.io/PRA/reference/ev.md),
[`ac`](https://paulgovan.github.io/PRA/reference/ac.md),
[`cv`](https://paulgovan.github.io/PRA/reference/cv.md),
[`spi`](https://paulgovan.github.io/PRA/reference/spi.md),
[`cpi`](https://paulgovan.github.io/PRA/reference/cpi.md),
[`eac`](https://paulgovan.github.io/PRA/reference/eac.md)

## Examples

``` r
# Set the BAC, schedule, and current time period for an example project.
bac <- 100000
schedule <- c(0.1, 0.2, 0.4, 0.7, 1.0)
time_period <- 3

# Calculate the PV.
pv <- pv(bac, schedule, time_period)

# Set the actual % complete and calculate the EV.
actual_per_complete <- 0.35
ev <- ev(bac, actual_per_complete)

# Calculate the SV and print the results.
sv <- sv(ev, pv)
cat("Schedule Variance (SV):", sv, "\n")
#> Schedule Variance (SV): -5000 
```
