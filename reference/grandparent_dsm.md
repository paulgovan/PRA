# Risk-based 'Grandparent' Design Structure Matrix (DSM).

Risk-based 'Grandparent' Design Structure Matrix (DSM).

## Usage

``` r
grandparent_dsm(S, R)
```

## Arguments

- S:

  Resource-Task Matrix 'S' giving the links (arcs) between resources and
  tasks.

- R:

  Risk-Resource Matrix 'R' giving the links (arcs) between risks and
  resources.

## Value

The function returns the Risk-based 'Grandparent' DSM 'G' giving the
number of risks shared between each task.

## Examples

``` r
# Set the S and R matrices and print the results.
S <- matrix(c(1, 1, 0, 0, 1, 0, 0, 1, 1), nrow = 3, ncol = 3)
R <- matrix(c(1, 1, 1, 1, 0, 0), nrow = 2, ncol = 3)
cat("Resource-Task Matrix:\n")
#> Resource-Task Matrix:
print(S)
#>      [,1] [,2] [,3]
#> [1,]    1    0    0
#> [2,]    1    1    1
#> [3,]    0    0    1
cat("\nRisk-Resource Matrix:\n")
#> 
#> Risk-Resource Matrix:
print(R)
#>      [,1] [,2] [,3]
#> [1,]    1    1    0
#> [2,]    1    1    0
# Calculate the Risk-based Grandparent Matrix and print the results.
risk_dsm <- grandparent_dsm(S, R)
cat("\nRisk-based 'Grandparent' DSM:\n")
#> 
#> Risk-based 'Grandparent' DSM:
print(risk_dsm)
#>      [,1] [,2] [,3]
#> [1,]    2    4    0
#> [2,]    4    8    0
#> [3,]    0    0    0
```
