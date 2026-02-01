# Variance at Completion (VAC).

Calculates the Variance at Completion (VAC), which is the difference
between the budget and the expected final cost. Positive VAC indicates
under budget, negative indicates over budget.

## Usage

``` r
vac(bac, eac)
```

## Arguments

- bac:

  Budget at Completion (BAC) (total planned budget).

- eac:

  Estimate at Completion.

## Value

The function returns the Variance at Completion (VAC).

## See also

[`eac`](https://paulgovan.github.io/PRA/reference/eac.md),
[`etc`](https://paulgovan.github.io/PRA/reference/etc.md),
[`tcpi`](https://paulgovan.github.io/PRA/reference/tcpi.md)

## Examples

``` r
bac <- 100000
eac <- 120482 # From EAC calculation

vac <- vac(bac, eac)
cat("Variance at Completion (VAC):", round(vac, 2), "\n")
#> Variance at Completion (VAC): -20482 
cat("Project is expected to be", abs(round(vac, 2)), ifelse(vac < 0, "over", "under"), "budget\n")
#> Project is expected to be 20482 over budget
```
