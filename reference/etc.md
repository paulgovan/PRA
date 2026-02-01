# Estimate to Complete (ETC).

Calculates the Estimate to Complete (ETC), which is the expected cost to
finish the remaining work.

## Usage

``` r
etc(bac, ev, cpi = NULL)
```

## Arguments

- bac:

  Budget at Completion (BAC) (total planned budget).

- ev:

  Earned Value.

- cpi:

  Cost Performance Index. If NULL, assumes remaining work will be
  completed at planned cost (ETC = BAC - EV). If provided, adjusts for
  current performance (ETC = (BAC - EV) / CPI).

## Value

The function returns the Estimate to Complete (ETC).

## See also

[`eac`](https://paulgovan.github.io/PRA/reference/eac.md),
[`vac`](https://paulgovan.github.io/PRA/reference/vac.md),
[`tcpi`](https://paulgovan.github.io/PRA/reference/tcpi.md)

## Examples

``` r
bac <- 100000
ev <- 35000
cpi <- 0.83

# ETC assuming remaining work at planned rate
etc <- etc(bac, ev)
cat("ETC (planned rate):", etc, "\n")
#> ETC (planned rate): 65000 

# ETC assuming remaining work at current CPI
etc <- etc(bac, ev, cpi)
cat("ETC (current CPI):", round(etc, 2), "\n")
#> ETC (current CPI): 78313.25 
```
