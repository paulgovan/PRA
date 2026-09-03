# Summarize a DSM object.

Summarizes the coupling structure of a Design Structure Matrix: how
densely the tasks are connected, how much coupling each task carries,
and which task pairs share the most resources (parent) or risks
(grandparent).

## Usage

``` r
# S3 method for class 'dsm'
summary(object, n_top = 5, ...)
```

## Arguments

- object:

  A `dsm` object returned by
  [`parent_dsm()`](https://paulgovan.github.io/PRA/reference/parent_dsm.md)
  or
  [`grandparent_dsm()`](https://paulgovan.github.io/PRA/reference/grandparent_dsm.md).

- n_top:

  Number of most strongly coupled task pairs to report. Defaults to 5.

- ...:

  Additional arguments (not used).

## Value

An object of class `"summary.dsm"`, a list with components:

- type:

  Either `"parent"` or `"grandparent"`.

- n_tasks, n_resources, n_risks:

  Dimensions of the underlying incidence matrices. `n_risks` is `NULL`
  for a parent DSM.

- density:

  Proportion of off-diagonal cells that are non-zero.

- total_coupling:

  Sum of the upper triangle, the total number of shared dependencies
  across all task pairs.

- own:

  Named numeric vector: the diagonal, each task's own count of resources
  (parent) or risks (grandparent).

- degree:

  Named numeric vector: each task's total coupling to the other tasks.

- top_pairs:

  Data frame of the `n_top` most strongly coupled task pairs, with
  columns `task_a`, `task_b` and `shared`.

## Examples

``` r
# A project with 3 tasks and 2 shared resources.
S <- matrix(c(
  1, 1, 0,
  0, 1, 1
), nrow = 2, byrow = TRUE)
colnames(S) <- c("Design", "Build", "Test")
p <- parent_dsm(S)
summary(p)
#> Resource-based 'Parent' Design Structure Matrix
#> ------------------------------
#> Tasks: 3  Resources: 2
#> Coupling density: 0.667 
#> Total shared dependencies: 2 
#> 
#> Coupling by task:
#> Design  Build   Test 
#>      1      2      1 
#> 
#> Most coupled task pairs (shared resources):
#>  task_a task_b shared
#>  Design  Build      1
#>   Build   Test      1
```
