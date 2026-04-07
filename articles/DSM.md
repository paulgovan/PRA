# Design Structure Matrices

A Design Structure Matrix (DSM) is a square matrix that maps
dependencies between tasks in a project. In PRA, DSMs are derived from
bipartite relationships: resources are shared across tasks, and risks
are shared across resources. These shared dependencies create coupling
between tasks that can propagate delays, cost overruns, or failures.

PRA provides two DSM functions:

- **[`parent_dsm()`](https://paulgovan.github.io/PRA/reference/parent_dsm.md)**
  — the Resource-based “Parent” DSM, showing how many resources are
  shared between each pair of tasks.
- **[`grandparent_dsm()`](https://paulgovan.github.io/PRA/reference/grandparent_dsm.md)**
  — the Risk-based “Grandparent” DSM, showing how many risks are shared
  between each pair of tasks (via the resource layer).

## The Resource-Task Matrix

The starting point is the Resource-Task Matrix **S**, where rows
represent resources and columns represent tasks. An entry `S[i, j] = 1`
means resource *i* is used by task *j*.

``` r
library(PRA)

# 4 resources x 5 tasks
S <- matrix(c(
  1, 0, 1, 0,
  1, 1, 0, 0,
  0, 1, 0, 1,
  0, 0, 1, 1,
  0, 1, 1, 0
), nrow = 4, ncol = 5)
rownames(S) <- paste0("R", 1:4)
colnames(S) <- paste0("T", 1:5)
S
#>    T1 T2 T3 T4 T5
#> R1  1  1  0  0  0
#> R2  0  1  1  0  1
#> R3  1  0  0  1  1
#> R4  0  0  1  1  0
```

## Parent DSM

The Parent DSM **P** = t(**S**) %*% **S** is a tasks-by-tasks matrix.
The diagonal entry `P[j, j]` counts how many resources task* j\* uses.
The off-diagonal entry `P[j, k]` counts how many resources tasks *j* and
*k* share — a measure of coupling.

``` r
p <- parent_dsm(S)
print(p)
#> Resource-based 'Parent' Design Structure Matrix
#> Tasks: 5  Resources: 4
#> 
#>    T1 T2 T3 T4 T5
#> T1  2  1  0  1  1
#> T2  1  2  1  0  1
#> T3  0  1  2  1  1
#> T4  1  0  1  2  1
#> T5  1  1  1  1  2
```

``` r
plot(p)
```

![Heatmap of the Parent DSM showing resource-based task
coupling](DSM_files/figure-html/unnamed-chunk-4-1.png)

Tasks that share more resources are more tightly coupled. If a resource
is delayed or constrained, all tasks that depend on it are affected.

## The Risk-Resource Matrix

The Risk-Resource Matrix **R** adds a second layer. Rows represent risks
and columns represent resources. An entry `R[i, j] = 1` means risk *i*
affects resource *j*.

``` r
# 3 risks x 4 resources
R <- matrix(c(
  1, 0, 1,
  1, 1, 0,
  0, 1, 0,
  0, 0, 1
), nrow = 3, ncol = 4)
rownames(R) <- paste0("Risk", 1:3)
colnames(R) <- paste0("R", 1:4)
R
#>       R1 R2 R3 R4
#> Risk1  1  1  0  0
#> Risk2  0  1  1  0
#> Risk3  1  0  0  1
```

## Grandparent DSM

The Grandparent DSM traces the dependency chain from risks through
resources to tasks. The intermediate matrix **T** = **R** %*% **S**
gives a risks-by-tasks mapping, and the Grandparent DSM is **G** =
t(**T**) %*% **T**. The off-diagonal entries count how many risks are
shared between each pair of tasks.

``` r
g <- grandparent_dsm(S, R)
print(g)
#> Risk-based 'Grandparent' Design Structure Matrix
#> Tasks: 5  Resources: 4  Risks: 3
#> 
#>    T1 T2 T3 T4 T5
#> T1  3  4  3  2  3
#> T2  4  6  4  2  4
#> T3  3  4  3  2  3
#> T4  2  2  2  2  2
#> T5  3  4  3  2  5
```

``` r
plot(g)
```

![Heatmap of the Grandparent DSM showing risk-based task
coupling](DSM_files/figure-html/unnamed-chunk-7-1.png)

## Interpreting the DSM

- **Diagonal values** indicate the total number of resources (Parent) or
  risks (Grandparent) associated with each task. Higher values mean a
  task has more dependencies.
- **Off-diagonal values** indicate coupling between task pairs. Higher
  values mean more shared dependencies and greater potential for
  correlated disruption.
- **Symmetric structure**: both DSMs are always symmetric since shared
  dependencies are bidirectional.

## References

Govan, Paul, and Ivan Damnjanovic. “The resource-based view on project
risk management.” *Journal of Construction Engineering and Management*
142.9 (2016): 04016034.
