# Schedule Performance Index (SPI).

Calculates the Schedule Performance Index (SPI) of work completed based
on the Earned Value (EV) and Planned Value (PV).

## Usage

``` r
spi(ev, pv)
```

## Arguments

- ev:

  Earned Value.

- pv:

  Planned Value.

## Value

The function returns the Schedule Performance Index (SPI) of work
completed.

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for
engineering and construction project risk management. No. 172534. Cham,
Switzerland: Springer, 2020.

## See also

[`pv`](https://paulgovan.github.io/PRA/reference/pv.md),
[`ev`](https://paulgovan.github.io/PRA/reference/ev.md),
[`ac`](https://paulgovan.github.io/PRA/reference/ac.md),
[`sv`](https://paulgovan.github.io/PRA/reference/sv.md),
[`cv`](https://paulgovan.github.io/PRA/reference/cv.md),
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

# Calculate the SPI and print the results.
spi <- spi(ev, pv)
cat("Schedule Performance Index (SPI):", spi, "\n")
#> Schedule Performance Index (SPI): 0.875 
```
