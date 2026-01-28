# Estimate at Completion (EAC).

Estimate at Completion (EAC).

## Usage

``` r
eac(bac, cpi)
```

## Arguments

- bac:

  Budget at Completion (BAC) (total planned budget).

- cpi:

  Cost Performance Index (CPI), the efficiency of cost utilization.

## Value

The function returns the Estimate at Completion (EAC).

## Examples

``` r
# Set the BAC and CPI for a toy project.
bac <- 100000
cpi <- 0.83

# Calculate the EAC
eac <- eac(bac, cpi)
print(eac)
#> [1] 120481.9
```
