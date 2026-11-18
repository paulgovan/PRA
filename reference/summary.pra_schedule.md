# Summarize a project schedule.

Summarize a project schedule.

## Usage

``` r
# S3 method for class 'pra_schedule'
summary(object, ...)
```

## Arguments

- object:

  An object of class `"pra_schedule"`.

- ...:

  Additional arguments (not used).

## Value

An object of class `"summary.pra_schedule"`, a list with the number of
activities, links, resources and risks; counts of activities by duration
source; counts of links by type; the start and end activities of the
network; and the deterministic finish and cost from
[`cpm()`](https://paulgovan.github.io/PRA/reference/cpm.md).

## Examples

``` r
proj <- project_schedule(
  data.frame(id = c("A", "B"), duration = c(2, 3)),
  data.frame(source = "A", target = "B")
)
summary(proj)
#> Project Schedule Summary
#> ------------------------
#> Activities: 2  (fixed: 2  distribution: 0  resource-driven: 0 )
#> Links: 1  ( FS: 1  SS: 0  FF: 0  SF: 0 )
#> Resources: 0  (capacity-limited: 0 )
#> Risk events: 0 
#> Start activities: A 
#> End activities: B 
#> Deterministic finish: 5 periods 
#> Deterministic cost: 0 
```
