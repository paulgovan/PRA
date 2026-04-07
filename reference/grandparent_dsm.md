# Risk-based 'Grandparent' Design Structure Matrix (DSM).

This function computes the Risk-based 'Grandparent' Design Structure
Matrix (DSM) from given Resource-Task Matrix 'S' and Risk-Resource
Matrix 'R'. The 'Grandparent' DSM indicates the number of risks shared
between each pair of tasks in a project.

## Usage

``` r
grandparent_dsm(S, R)
```

## Arguments

- S:

  Resource-Task Matrix 'S' giving the links (arcs) between resources and
  tasks. Rows represent resources and columns represent tasks.

- R:

  Risk-Resource Matrix 'R' giving the links (arcs) between risks and
  resources. Rows represent risks and columns represent resources.

## Value

An S3 object of class `"dsm"` with the following components:

- matrix:

  The Risk-based 'Grandparent' DSM giving the number of risks shared
  between each task.

- type:

  Character string `"grandparent"`.

- n_tasks:

  Number of tasks (columns in S).

- n_resources:

  Number of resources (rows in S).

- n_risks:

  Number of risks (rows in R).

## References

Govan, Paul, and Ivan Damnjanovic. "The resource-based view on project
risk management." Journal of construction engineering and management
142.9 (2016): 04016034.

## Examples

``` r
# Set the S and R matrices and print the results.
S <- matrix(c(1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1), nrow = 3, ncol = 4)
R <- matrix(c(1, 1, 0, 1, 0, 0), nrow = 2, ncol = 3)
cat("Resource-Task Matrix (3 resources x 4 tasks):\n")
#> Resource-Task Matrix (3 resources x 4 tasks):
print(S)
#>      [,1] [,2] [,3] [,4]
#> [1,]    1    0    1    0
#> [2,]    1    1    0    1
#> [3,]    0    0    0    1
cat("\nRisk-Resource Matrix (2 risks x 3 resources):\n")
#> 
#> Risk-Resource Matrix (2 risks x 3 resources):
print(R)
#>      [,1] [,2] [,3]
#> [1,]    1    0    0
#> [2,]    1    1    0
# Calculate the Risk-based Grandparent Matrix and print the results.
risk_dsm <- grandparent_dsm(S, R)
print(risk_dsm)
#> Risk-based 'Grandparent' Design Structure Matrix
#> Tasks: 4  Resources: 3  Risks: 2
#> 
#>      [,1] [,2] [,3] [,4]
#> [1,]    5    2    3    2
#> [2,]    2    1    1    1
#> [3,]    3    1    2    1
#> [4,]    2    1    1    1
```
