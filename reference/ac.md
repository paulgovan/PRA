# Actual Cost (AC).

Actual Cost (AC).

## Usage

``` r
ac(actual_costs, time_period)
```

## Arguments

- actual_costs:

  Vector of actual costs incurred at each time period.

- time_period:

  Current time period.

## Value

The function returns the Actual Cost (AC) of work completed.

## Examples

``` r
# Set the actual costs and current time period for a toy project.
actual_costs <- c(9000, 18000, 36000, 70000, 100000)
time_period <- 3

# Calculate the AC and print the results.
ac <- ac(actual_costs, time_period)
cat("Actual Cost (AC):", ac, "\n")
#> Actual Cost (AC): 36000 
```
