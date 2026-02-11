# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## Package Overview

PRA (Project Risk Analysis) is an R package for quantitative project
risk analysis. It provides methods for schedule/cost uncertainty
analysis, earned value management, learning curves, Bayesian risk
inference, and dependency structure matrices. Published on CRAN
(v0.3.0).

## Build & Development Commands

``` r
# Install development dependencies
devtools::install_dev_deps()

# Full package check (build + tests + examples + vignettes)
devtools::check()

# Run all tests
devtools::test()

# Run a single test file
testthat::test_file("tests/testthat/test-mcs.R")

# Regenerate documentation (NAMESPACE + man/ pages)
devtools::document()

# Build vignettes
devtools::build_vignettes()
```

## Architecture

Each analytical method lives in its own file under `R/` with a
corresponding test file under `tests/testthat/`:

| Module                  | File            | Key exports                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
|-------------------------|-----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Monte Carlo Simulation  | `mcs.R`         | [`mcs()`](https://paulgovan.github.io/PRA/reference/mcs.md), [`print.mcs()`](https://paulgovan.github.io/PRA/reference/print.mcs.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| Second Moment Method    | `smm.R`         | [`smm()`](https://paulgovan.github.io/PRA/reference/smm.md), [`print.smm()`](https://paulgovan.github.io/PRA/reference/print.smm.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| Earned Value Management | `evm.R`         | [`pv()`](https://paulgovan.github.io/PRA/reference/pv.md), [`ev()`](https://paulgovan.github.io/PRA/reference/ev.md), [`ac()`](https://paulgovan.github.io/PRA/reference/ac.md), [`sv()`](https://paulgovan.github.io/PRA/reference/sv.md), [`cv()`](https://paulgovan.github.io/PRA/reference/cv.md), [`spi()`](https://paulgovan.github.io/PRA/reference/spi.md), [`cpi()`](https://paulgovan.github.io/PRA/reference/cpi.md), [`eac()`](https://paulgovan.github.io/PRA/reference/eac.md), [`etc()`](https://paulgovan.github.io/PRA/reference/etc.md), [`tcpi()`](https://paulgovan.github.io/PRA/reference/tcpi.md), [`vac()`](https://paulgovan.github.io/PRA/reference/vac.md) |
| Contingency Analysis    | `contingency.R` | [`contingency()`](https://paulgovan.github.io/PRA/reference/contingency.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Sensitivity Analysis    | `sensitivity.R` | [`sensitivity()`](https://paulgovan.github.io/PRA/reference/sensitivity.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Learning Curves         | `sigmoidal.R`   | [`fit_sigmoidal()`](https://paulgovan.github.io/PRA/reference/fit_sigmoidal.md), [`predict_sigmoidal()`](https://paulgovan.github.io/PRA/reference/predict_sigmoidal.md), [`plot_sigmoidal()`](https://paulgovan.github.io/PRA/reference/plot_sigmoidal.md)                                                                                                                                                                                                                                                                                                                                                                                                                           |
| Bayesian Risk           | `inference.R`   | [`risk_prob()`](https://paulgovan.github.io/PRA/reference/risk_prob.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
| Bayesian Learning       | `learning.R`    | [`risk_post_prob()`](https://paulgovan.github.io/PRA/reference/risk_post_prob.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| Correlation Matrices    | `cormat.R`      | [`cor_matrix()`](https://paulgovan.github.io/PRA/reference/cor_matrix.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| Design Structure Matrix | `dsm.R`         | [`parent_dsm()`](https://paulgovan.github.io/PRA/reference/parent_dsm.md), [`grandparent_dsm()`](https://paulgovan.github.io/PRA/reference/grandparent_dsm.md)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |

## Key Conventions

- **Documentation**: roxygen2 with Markdown syntax. The roxygen config
  includes `srr::srr_stats_roclet` for rOpenSci statistical software
  review standards (see `R/srr-stats-standards.R`).
- **Testing**: testthat edition 3. Test files mirror source files
  (`R/foo.R` → `tests/testthat/test-foo.R`).
- **Dependencies**: minimal — `mc2d` (triangular distributions),
  `minpack.lm` (nonlinear least squares), `stats`.
- **Input validation**: all public functions validate inputs for type,
  length, NA/NaN/Inf. Error messages must be unique and informative (SRR
  standard G5.2a).
- **S3 classes**:
  [`mcs()`](https://paulgovan.github.io/PRA/reference/mcs.md) and
  [`smm()`](https://paulgovan.github.io/PRA/reference/smm.md) return
  custom S3 objects with print methods.

## CI/CD

GitHub Actions workflows in `.github/workflows/`: - `R-CMD-check.yaml` —
runs `R CMD check` on macOS, Windows, Ubuntu across R
release/devel/oldrel - `test-coverage.yaml` — code coverage via `covr`
uploaded to Codecov - `pkgdown.yaml` — builds documentation site
