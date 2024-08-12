
<!-- README.md is generated from README.Rmd. Please edit that file -->

## PRA: Project Risk Analysis in R

<img
src="https://github.com/paulgovan/PRA/blob/main/inst/logo.png?raw=true"
style="width:25.0%" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/PRA)](https://CRAN.R-project.org/package=PRA)
[![CRAN
checks](https://badges.cranchecks.info/summary/PRA.svg)](https://cran.r-project.org/web/checks/check_results_PRA.html)
[![](http://cranlogs.r-pkg.org/badges/grand-total/PRA)](https://cran.r-project.org/package=PRA)
[![](http://cranlogs.r-pkg.org/badges/last-month/PRA)](https://cran.r-project.org/package=PRA)
[![](https://img.shields.io/badge/doi-10.32614/CRAN.package.eAnalytics-green.svg)](https://doi.org/10.32614/CRAN.package.PRA)
<!-- badges: end -->

## Key features:

- The Second Moment Method
- Monte Carlo Simulation
- Contingency Analysis
- Sensitivity Analysis
- Earned Value Management
- Learning Curves
- Design Structure Matrices
- And more!

## Installation

To install the release verion of PRA, use:

``` r
install_packages('PRA')
```

You can install the development version of PRA like so:

``` r
devtools::install_github('paulgovan/PRA')
```

## Usage

Here is a basic example which shows you how to solve a common problem
using Monte Carlo Simulation.

First, load the package:

``` r
library(PRA)
```

Next, set the number of simulations and describe probability
distributions for 3 work packages:

``` r
num_simulations <- 10000
task_distributions <- list(
  list(type = "normal", mean = 10, sd = 2),  # Task A: Normal distribution
  list(type = "triangular", a = 5, b = 10, c = 15),  # Task B: Triangular distribution
  list(type = "uniform", min = 8, max = 12)  # Task C: Uniform distribution
)
```

Then, set the correlation matrix between the 3 work packages:

``` r
correlation_matrix <- matrix(c(
  1, 0.5, 0.3,
  0.5, 1, 0.4,
  0.3, 0.4, 1
), nrow = 3, byrow = TRUE)
```

Finally, run the simulation using the `mcs` function:

``` r
results <- mcs(num_simulations, task_distributions, correlation_matrix)
```

To calculate the mean of the total duration:

``` r
cat("Mean Total Duration:", results$total_mean, "\n")
#> Mean Total Duration: 38.57388
```

To calculate the variance of the total duration:

``` r
cat("Variance of Total Duration:", results$total_variance, "\n")
#> Variance of Total Duration: 19.65191
```

To build a histogram of the total duration:

``` r
hist(results$total_distribution, breaks = 50, main = "Distribution of Total Project Duration", 
     xlab = "Total Duration", col = "skyblue", border = "white")
```

<img src="man/figures/README-unnamed-chunk-8-1.png" width="100%" />

## More Resources

Much of this package is based on the book [Data Analysis for Engineering
and Project Risk Managment](https://doi.org/10.1007/978-3-030-14251-3)
by Ivan Damnjanovic and Ken Reinschmidt and comes highly recommended.

## Code of Conduct

Please note that the PRA project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
