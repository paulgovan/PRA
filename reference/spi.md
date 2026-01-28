# Schedule Performance Index (SPI).

Schedule Performance Index (SPI).

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
