# To-Complete Performance Index (TCPI).

Calculates the To-Complete Performance Index (TCPI), which indicates the
cost performance required on remaining work to meet a target (BAC or
EAC). TCPI \> 1 means efficiency must improve; TCPI \< 1 means
efficiency can decrease.

## Usage

``` r
tcpi(bac, ev, ac, target = "bac", eac = NULL)
```

## Arguments

- bac:

  Budget at Completion (BAC) (total planned budget).

- ev:

  Earned Value.

- ac:

  Actual Cost.

- target:

  The target to calculate TCPI against. Either "bac" (default) to meet
  original budget, or "eac" to meet revised estimate. If "eac", the eac
  parameter must be provided.

- eac:

  Estimate at Completion. Required when target = "eac".

## Value

The function returns the To-Complete Performance Index (TCPI).

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for
engineering and construction project risk management. No. 172534. Cham,
Switzerland: Springer, 2020.

## See also

[`eac`](https://paulgovan.github.io/PRA/reference/eac.md),
[`etc`](https://paulgovan.github.io/PRA/reference/etc.md),
[`vac`](https://paulgovan.github.io/PRA/reference/vac.md),
[`cpi`](https://paulgovan.github.io/PRA/reference/cpi.md)

## Examples

``` r
bac <- 100000
ev <- 35000
ac <- 63000

# TCPI to complete within original budget
tcpi_bac <- tcpi(bac, ev, ac)
cat("TCPI (to meet BAC):", round(tcpi_bac, 2), "\n")
#> TCPI (to meet BAC): 1.76 

# TCPI to complete within revised estimate
eac <- 120482
tcpi_eac <- tcpi(bac, ev, ac, target = "eac", eac = eac)
cat("TCPI (to meet EAC):", round(tcpi_eac, 2), "\n")
#> TCPI (to meet EAC): 1.13 
```
