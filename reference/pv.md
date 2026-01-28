# Planned Value (PV).

Planned Value (PV).

## Usage

``` r
pv(bac, schedule, time_period)
```

## Arguments

- bac:

  Budget at Completion (BAC) (total planned budget).

- schedule:

  Vector of planned work completion (in terms of percentage) at each
  time period.

- time_period:

  Current time period.

## Value

The function returns the Planned Value (PV) of work completed.

## Examples

``` r
# Set the BAC, schedule, and current time period for a toy project.
bac <- 100000
schedule <- c(0.1, 0.2, 0.4, 0.7, 1.0)
time_period <- 3

# Calculate the PV and print the results.
pv <- pv(bac, schedule, time_period)
cat("Planned Value (PV):", pv, "\n")
#> Planned Value (PV): 40000 
```
