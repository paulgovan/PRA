# Estimate at Completion (EAC).

Calculates the Estimate at Completion (EAC) using various methods based
on project performance assumptions.

## Usage

``` r
eac(bac, method = "typical", cpi = NULL, ac = NULL, ev = NULL, spi = NULL)
```

## Arguments

- bac:

  Budget at Completion (BAC) (total planned budget).

- method:

  The EAC calculation method. One of:

  - "typical" (default): EAC = BAC / CPI. Assumes future work performed
    at current cost efficiency.

  - "atypical": EAC = AC + (BAC - EV). Assumes future work performed at
    planned rate.

  - "combined": EAC = AC + (BAC - EV) / (CPI \* SPI). Considers both
    cost and schedule performance.

- cpi:

  Cost Performance Index (CPI). Required for "typical" and "combined"
  methods.

- ac:

  Actual Cost. Required for "atypical" and "combined" methods.

- ev:

  Earned Value. Required for "atypical" and "combined" methods.

- spi:

  Schedule Performance Index. Required for "combined" method.

## Value

The function returns the Estimate at Completion (EAC).

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
[`spi`](https://paulgovan.github.io/PRA/reference/spi.md),
[`cpi`](https://paulgovan.github.io/PRA/reference/cpi.md),
[`etc`](https://paulgovan.github.io/PRA/reference/etc.md),
[`vac`](https://paulgovan.github.io/PRA/reference/vac.md),
[`tcpi`](https://paulgovan.github.io/PRA/reference/tcpi.md)

## Examples

``` r
# Method 1: Typical - assumes current CPI continues
bac <- 100000
cpi <- 0.83
eac <- eac(bac, cpi = cpi)
cat("EAC (typical):", round(eac, 2), "\n")
#> EAC (typical): 120481.9 

# Method 2: Atypical - assumes future work at planned rate
ac <- 63000
ev <- 35000
eac <- eac(bac, method = "atypical", ac = ac, ev = ev)
cat("EAC (atypical):", round(eac, 2), "\n")
#> EAC (atypical): 128000 

# Method 3: Combined - considers both CPI and SPI
spi <- 0.875
eac <- eac(bac, method = "combined", cpi = cpi, ac = ac, ev = ev, spi = spi)
cat("EAC (combined):", round(eac, 2), "\n")
#> EAC (combined): 152500.9 
```
