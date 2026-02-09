# Resource-based 'Parent' Design Structure Matrix (DSM).

This function computes the Resource-based 'Parent' Design Structure
Matrix (DSM) from a given Resource-Task Matrix 'S'. The 'Parent' DSM
indicates the number of resources shared between each pair of tasks in a
project.

## Usage

``` r
parent_dsm(S)
```

## Arguments

- S:

  Resource-Task Matrix 'S' giving the links (arcs) between resources and
  tasks.

## Value

The function returns the Resource-based 'Parent' DSM 'P' giving the
number of resources shared between each task.

## References

Govan, Paul, and Ivan Damnjanovic. "The resource-based view on project
risk management." Journal of construction engineering and management
142.9 (2016): 04016034.

## Examples

``` r
# Set the S matrix for a toy project and print the results.
s <- matrix(c(1, 1, 0, 0, 1, 0, 0, 1, 1), nrow = 3, ncol = 3)
cat("Resource-Task Matrix:\n")
#> Resource-Task Matrix:
print(s)
#>      [,1] [,2] [,3]
#> [1,]    1    0    0
#> [2,]    1    1    1
#> [3,]    0    0    1

# Calculate the Resource-based Parent DSM and print the results.
resource_dsm <- parent_dsm(s)
cat("\nResource-based 'Parent' DSM:\n")
#> 
#> Resource-based 'Parent' DSM:
print(resource_dsm)
#>      [,1] [,2] [,3]
#> [1,]    1    1    0
#> [2,]    1    3    1
#> [3,]    0    1    1
```
