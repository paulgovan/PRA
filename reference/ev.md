# Earned Value (EV).

Earned Value (EV).

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
