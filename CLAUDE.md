# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

PRA (Project Risk Analysis) is an R package for quantitative project risk analysis. It provides methods for schedule/cost uncertainty analysis, earned value management, learning curves, Bayesian risk inference, and dependency structure matrices. Published on CRAN (v0.3.0).

## Build & Development Commands

```r
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

Each analytical method lives in its own file under `R/` with a corresponding test file under `tests/testthat/`:

| Module | File | Key exports |
|--------|------|-------------|
| Monte Carlo Simulation | `mcs.R` | `mcs()`, `print.mcs()` |
| Second Moment Method | `smm.R` | `smm()`, `print.smm()` |
| Earned Value Management | `evm.R` | `pv()`, `ev()`, `ac()`, `sv()`, `cv()`, `spi()`, `cpi()`, `eac()`, `etc()`, `tcpi()`, `vac()` |
| Contingency Analysis | `contingency.R` | `contingency()` |
| Sensitivity Analysis | `sensitivity.R` | `sensitivity()` |
| Learning Curves | `sigmoidal.R` | `fit_sigmoidal()`, `predict_sigmoidal()`, `plot_sigmoidal()` |
| Bayesian Risk | `inference.R` | `risk_prob()` |
| Bayesian Learning | `learning.R` | `risk_post_prob()` |
| Correlation Matrices | `cormat.R` | `cor_matrix()` |
| Design Structure Matrix | `dsm.R` | `parent_dsm()`, `grandparent_dsm()` |

## Key Conventions

- **Documentation**: roxygen2 with Markdown syntax. The roxygen config includes `srr::srr_stats_roclet` for rOpenSci statistical software review standards (see `R/srr-stats-standards.R`).
- **Testing**: testthat edition 3. Test files mirror source files (`R/foo.R` → `tests/testthat/test-foo.R`).
- **Dependencies**: minimal — `mc2d` (triangular distributions), `minpack.lm` (nonlinear least squares), `stats`.
- **Input validation**: all public functions validate inputs for type, length, NA/NaN/Inf. Error messages must be unique and informative (SRR standard G5.2a).
- **S3 classes**: `mcs()` and `smm()` return custom S3 objects with print methods.

## CI/CD

GitHub Actions workflows in `.github/workflows/`:
- `R-CMD-check.yaml` — runs `R CMD check` on macOS, Windows, Ubuntu across R release/devel/oldrel
- `test-coverage.yaml` — code coverage via `covr` uploaded to Codecov
- `pkgdown.yaml` — builds documentation site
