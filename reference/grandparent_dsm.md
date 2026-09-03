# Risk-based 'Grandparent' Design Structure Matrix (DSM).

This function computes the Risk-based 'Grandparent' Design Structure
Matrix (DSM) from given Resource-Task Matrix 'S' and Risk-Resource
Matrix 'R'. The 'Grandparent' DSM scores the risk exposure that each
pair of tasks shares through the resource chain. Entry \\G\_{jk}\\ sums,
over risks, the product of the risk-to-task path counts \\(RS)\_{ij}\\
and \\(RS)\_{ik}\\, so a shared risk is weighted by the number of common
resources carrying it; this reduces to a plain count of shared risks
only when \\RS\\ is binary.

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

  The Risk-based 'Grandparent' DSM giving the shared risk-exposure score
  for each task pair.

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
S <- matrix(c(1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 1), nrow = 3, ncol = 4,
            dimnames = list(
              c("Resource-1", "Resource-2", "Resource-3"),
              c("Task-1", "Task-2", "Task-3", "Task-4")
            ))
R <- matrix(c(1, 1, 0, 1, 0, 0), nrow = 2, ncol = 3,
            dimnames = list(
              c("Risk-1", "Risk-2"),
              c("Resource-1", "Resource-2", "Resource-3")
            ))
cat("Resource-Task Matrix (3 resources x 4 tasks):\n")
#> Resource-Task Matrix (3 resources x 4 tasks):
print(S)
#>            Task-1 Task-2 Task-3 Task-4
#> Resource-1      1      0      1      0
#> Resource-2      1      1      0      1
#> Resource-3      0      0      0      1
cat("\nRisk-Resource Matrix (2 risks x 3 resources):\n")
#> 
#> Risk-Resource Matrix (2 risks x 3 resources):
print(R)
#>        Resource-1 Resource-2 Resource-3
#> Risk-1          1          0          0
#> Risk-2          1          1          0
# Calculate the Risk-based Grandparent Matrix and print the results.
risk_dsm <- grandparent_dsm(S, R)
print(risk_dsm)
#> Risk-based 'Grandparent' Design Structure Matrix
#> Tasks: 4  Resources: 3  Risks: 2
#> 
#>        Task-1 Task-2 Task-3 Task-4
#> Task-1      5      2      3      2
#> Task-2      2      1      1      1
#> Task-3      3      1      2      1
#> Task-4      2      1      1      1
```
