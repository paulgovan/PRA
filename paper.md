---
title: 'PRA: An R Package for Quantitative Project Risk Analysis'
tags:
  - R
  - project management
  - risk analysis
  - Monte Carlo simulation
  - earned value management
  - Bayesian inference
authors:
  - name: Paul Govan
    orcid: 0000-0002-1821-8492
    affiliation: 1
affiliations:
  - name: Independent Researcher
    index: 1
date: 20 May 2026
bibliography: paper.bib
---

# Summary

`PRA` is an R package for quantitative project risk management. It provides a
unified, open-source implementation of the core analytical methods used in cost
engineering and schedule risk analysis: Monte Carlo simulation (MCS), the
Second Moment Method (SMM), Earned Value Management (EVM), contingency
analysis, sensitivity analysis, Bayesian risk inference, sigmoidal learning
curves, and Design Structure Matrices (DSM). The package is available on CRAN
and targets practitioners and researchers working in project risk, cost
engineering, and construction management. Source code and documentation are
available at <https://github.com/paulgovan/PRA>.

# Statement of Need

Quantitative risk analysis for projects requires integrating several
methodologically distinct techniques — probabilistic simulation, performance
measurement, Bayesian updating, dependency modeling — that are typically
scattered across commercial tools, spreadsheets, or single-purpose scripts. No
prior R package provides a cohesive, peer-reviewed implementation of this full
suite. `PRA` addresses this gap by consolidating these methods in a minimal,
well-tested package that adheres to rOpenSci Statistical Software Review (SRR)
standards [@rOpenSciStats2021], enabling reproducible analyses directly in R.

The package is particularly useful in early project phases when uncertainty is
high and formal risk quantification can guide contingency budgeting and
schedule buffering decisions [@Damnjanovic2020].

# State of the Field

Commercial tools such as Palisade @RISK (Oracle) and Primavera Risk Analysis
are widely used for project risk simulation but are proprietary, expensive, and
not reproducible in open scientific workflows. Within R, no single package
covers the full project risk analysis workflow. The `mc2d` package provides
general-purpose two-dimensional Monte Carlo simulation but has no
project-specific constructs (task networks, EVM, contingency). The `sensitivity`
package implements variance-based sensitivity indices for general functions but
does not integrate with schedule or cost models. EVM metrics are absent from
CRAN entirely. Bayesian inference packages such as `rstan` and `brms` operate
at a much higher level of generality and require substantial user expertise to
apply to project risk contexts.

`PRA` fills this gap by providing a domain-specific, batteries-included toolkit
that covers the complete analytical lifecycle from initial uncertainty
estimation through performance monitoring and Bayesian updating, with minimal
dependencies and a consistent API.

# Functionality

## Monte Carlo Simulation

The `mcs()` function propagates schedule and cost uncertainty through a
project network using triangular, normal, and uniform distributions. Task
correlations are modeled via Cholesky decomposition [@Vose2008]. Results
include full empirical distributions and standard percentile summaries
(P5–P95).

## Second Moment Method

`smm()` provides an analytical alternative to simulation: it approximates
project-level mean and variance from task-level first and second moments,
invoking the Central Limit Theorem. This is useful for rapid early-stage
estimates where full distributional assumptions are not yet justified
[@Damnjanovic2020].

## Earned Value Management

The EVM module implements the complete ANSI/EIA-748 suite of eleven
performance metrics: Planned Value (PV), Earned Value (EV), Actual Cost (AC),
Schedule Variance (SV), Cost Variance (CV), Schedule Performance Index (SPI),
Cost Performance Index (CPI), Estimate at Completion (EAC, three methods),
Estimate to Complete (ETC), To-Complete Performance Index (TCPI), and
Variance at Completion (VAC) [@Fleming2010].

## Contingency Analysis and Sensitivity Analysis

`contingency()` derives cost or schedule reserve buffers as the difference
between a user-specified simulation percentile (e.g., P80 or P95) and the
base estimate. `sensitivity()` decomposes total project variance by task
contribution, enabling Tornado-style identification of the dominant risk
drivers [@Damnjanovic2020].

## Bayesian Risk Inference

`risk_prob()` computes overall risk event probability from root-cause priors
and conditional likelihoods using the total probability theorem.
`risk_post_prob()` updates these probabilities with observed evidence via
Bayes' theorem. The conjugate Beta-Binomial model in `cost_pdf()` and
`cost_post_pdf()` extends this framework to cost risk distributions
[@Gelman2013].

## Learning Curves

`fit_sigmoidal()` fits three S-curve models (Logistic, Gompertz, Pearl) to
cumulative completion data using nonlinear least squares via `minpack.lm`
[@Elzhov2016]. `predict_sigmoidal()` forecasts future task completion dates,
and `plot_sigmoidal()` provides visualization.

## Design Structure Matrices

`parent_dsm()` and `grandparent_dsm()` construct resource-task and
risk-resource-task dependency matrices, respectively. These support
identification of task coupling and risk propagation paths in complex project
networks [@Browning2001].

## AI Agent Interface

`PRA` v0.4.0 includes an agentic interface (`pra_chat()`, `pra_app()`) that
exposes all analytical functions as tools callable by large language models via
the `ellmer` package [@ellmer]. A Retrieval-Augmented Generation (RAG) layer,
built on `ragnar` [@ragnar] with local Ollama models, grounds agent responses
in domain-specific risk literature. The package also exports `pra_mcp_server()`
to serve all tools via the Model Context Protocol [@MCP2024], enabling
integration with Claude, Claude Code, and other MCP-compatible AI clients.

# Software Design

`PRA` is structured as a collection of independent analytical modules, each in
its own source file under `R/`, with a corresponding test file under
`tests/testthat/`. This one-module-per-file layout keeps individual files
small, makes the dependency graph explicit, and allows modules to be tested in
isolation.

All public functions follow a consistent input-validation-first pattern:
inputs are checked for correct type, length, and the absence of NA, NaN, and
Inf values before any computation occurs, following SRR standards G2.0–G2.16.
Error messages are unique per call site (SRR G5.2a) to aid debugging.

The AI agent layer (`R/chat.R`, `R/tools.R`, `R/rag.R`) is kept strictly
optional via the `Suggests` mechanism: the 36 exported analytical functions
work without any AI dependency. When AI features are used, tool definitions
are built with `ellmer::tool()` and reused identically for both the
conversational chat interface and the MCP server, avoiding duplication. The
RAG store uses DuckDB via `ragnar`, enabling hybrid vector and keyword search
over the bundled domain knowledge files without requiring a network connection.

The package uses minimal hard dependencies (`mc2d`, `minpack.lm`, `stats`)
to reduce installation friction and downstream breakage risk.

# Quality and Testing

All 36 exported functions validate inputs for type, length, and special values
(NA, NaN, Inf) following rOpenSci SRR standards G2.0–G2.16. The test suite
contains over 640 test cases with more than 1,200 assertions covering
error/warning behavior, parameter recovery, edge conditions, noise
susceptibility, and algorithmic correctness, run via `testthat` [@testthat]
and verified through GitHub Actions CI on macOS, Windows, and Ubuntu across
R release, devel, and oldrel. Code coverage is tracked via Codecov.

# AI Usage Disclosure

The AI agent interface within `PRA` uses large language models at runtime as
an optional feature: `pra_chat()` connects to a locally-running Ollama model
(default: `llama3.2`) or a user-supplied `ellmer` chat object, and
`pra_mcp_server()` exposes PRA tools to external AI clients via the Model
Context Protocol. These are deliberate, documented design choices in the
software itself, not uses of generative AI in the development process.

During development, Claude Code (Anthropic) was used to assist with drafting
documentation, generating test scaffolding, and reviewing code. All
substantive design decisions, algorithmic implementations, and final content
were authored and verified by the package maintainer.

# References
