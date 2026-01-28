# Cost Performance Index (CPI).

Cost Performance Index (CPI).

## Usage

``` r
cpi(ev, ac)
```

## Arguments

- ev:

  Earned Value.

- ac:

  Actual Cost.

## Value

The function returns the Cost Performance Index (CPI) of work completed.

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

# Calculate the CPI and print the results.
cpi <- cpi(ev, ac)
cat("Cost Performance Index (CPI):", cpi, "\n")
#> Cost Performance Index (CPI): 0.9722222 
```
