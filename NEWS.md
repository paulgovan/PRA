# NEWS

## v0.6.0
- **`cor_matrix()` now draws column `i` from distribution `i`** (previously
  random with replacement, so columns could repeat or omit inputs); columns
  are now labelled with distribution names. Results will differ.
- Correlation-matrix checks (symmetry, `[-1, 1]` range, unit diagonal) are now
  shared across `mcs()`, `smm()`, and `sensitivity()`.
- `sensitivity()` warns when an index is negative, which can happen under
  negative correlation.
- `cost_pdf()` no longer requires `sum(risk_probs) <= 1`.
- `cost_post_pdf()` gained `risk_probs`, so unobserved (`NA`) risks are drawn
  from their prior instead of treated as absent; warns if omitted with NAs
  present.
- `predict_sigmoidal()` now errors on a `model_type`/`fit` mismatch instead of
  returning `NA` confidence bounds.

## v0.5.0
- **`mcs()` fixes the Cholesky decomposition for correlated tasks** — target
  correlations and marginal means were previously distorted. Correlated
  results will differ; independent tasks are unaffected.
- **AI integration is now MCP-only.** Removed `pra_chat()`, `pra_app()`,
  slash commands, and the RAG functions; use `pra_mcp_server()` and the
  bundled Agent Skills (`inst/skills/`) instead.
- Dropped `ragnar`, `shiny`, `shinychat`, `bslib`, `vitals`, `mockr`; added
  `corrplot`, `igraph`, `networkD3`, `devtools`, `remotes`, `mcptools`.
- **New (experimental) probabilistic network module:** `prob_net()`,
  `prob_net_sim()`, `prob_net_learn()`, `prob_net_update()`.
- **Probabilistic networks (breaking):** `links` are now load-bearing —
  edges must match the distributions' dependencies, nodes must be
  topologically ordered, and `adjacency_matrix` is now directed. Networks
  that were already self-consistent are unaffected.
- **Bayesian risk (breaking):** `risk_prob()`/`risk_post_prob()` combine
  multiple causes with a noisy-OR, keeping results in `[0, 1]`. Single-cause
  results are unchanged.
- **Sensitivity analysis (breaking):** `sensitivity()` indices now reflect
  each task's actual variance contribution instead of always returning 1.0
  for independent tasks.
- Added the `building_project` example dataset.
- Vignettes migrated to a companion Quarto book and a new JSS paper
  (`inst/paper/pra-jss/`).
- License changed from CC BY 4.0 to MIT + file LICENSE.

## v0.4.0
- DSM Improvements
- Bayesian Improvements
- **Agentic AI Framework**  
  - Slash Commands  
  - Natural Language Interface  
  - RAG-enhanced Reasoning  
  - Local Execution via Ollama  
  - Shiny App  
  - Evaluation Framework

## v0.3.0
- Previous changes and improvements...

## v0.2.0
- Previous changes and improvements...

## v0.1.0
- Previous changes and improvements...