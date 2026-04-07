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
  tasks. Rows represent resources and columns represent tasks.

## Value

An S3 object of class `"dsm"` with the following components:

- matrix:

  The Resource-based 'Parent' DSM giving the number of resources shared
  between each task.

- type:

  Character string `"parent"`.

- n_tasks:

  Number of tasks (columns in S).

- n_resources:

  Number of resources (rows in S).

## References

Govan, Paul, and Ivan Damnjanovic. "The resource-based view on project
risk management." Journal of construction engineering and management
142.9 (2016): 04016034.

## Examples

``` r
# Set the S matrix for a toy project (3 resources x 4 tasks).
s <- matrix(c(1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1), nrow = 3, ncol = 4)
cat("Resource-Task Matrix:\n")
#> Resource-Task Matrix:
print(s)
#>      [,1] [,2] [,3] [,4]
#> [1,]    1    0    1    0
#> [2,]    1    1    0    1
#> [3,]    0    0    0    1

# Calculate the Resource-based Parent DSM and print the results.
resource_dsm <- parent_dsm(s)
print(resource_dsm)
#> Resource-based 'Parent' Design Structure Matrix
#> Tasks: 4  Resources: 3
#> 
#>      [,1] [,2] [,3] [,4]
#> [1,]    2    1    1    1
#> [2,]    1    1    0    1
#> [3,]    1    0    1    0
#> [4,]    1    1    0    2
```
