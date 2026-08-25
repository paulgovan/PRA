# NEWS

## v0.6.0
- **`cor_matrix()` now draws column `i` from distribution `i`.** It previously
  sampled a distribution at random, with replacement, for each column, so a
  column did not necessarily correspond to its input distribution — with three
  distributions, roughly half of all runs sampled one of them twice and
  omitted another entirely. Output columns are now labelled with the
  distribution names, as the documentation already claimed. Results from
  `cor_matrix()` will differ from earlier versions.
- Correlation-matrix validation is now shared across `mcs()`, `smm()`, and
  `sensitivity()` through a new internal `validate_cor_mat()`, which adds the
  previously missing symmetry, `[-1, 1]` range, and unit-diagonal checks. A
  non-symmetric matrix was previously accepted silently.
- `sensitivity()` now warns when a task's index comes out negative, which can
  happen under negative correlation; indices still sum to 1, but a negative
  bar has no Tornado-chart reading.
- `cost_pdf()` no longer requires `sum(risk_probs) <= 1`; the risks are
  independent Bernoulli events, so any number of them may occur together and
  the probabilities need not sum to 1.
- `cost_post_pdf()` gained a `risk_probs` argument. An unobserved (`NA`) risk
  is now drawn from its prior when supplied, rather than always treated as
  absent — matching how `risk_post_prob()` already treats an unobserved
  cause. Warns when `risk_probs` is omitted and `NA`s are present, since
  dropping them understates cost. Threaded through `cost_post_pdf_tool()` and
  its MCP schema.
- `predict_sigmoidal()` now errors on a `model_type`/`fit` mismatch instead of
  silently producing `NA` confidence bounds.

## v0.5.0
- **`mcs()` now applies the Cholesky decomposition correctly for correlated
  tasks.** The Cholesky factor is applied to independent standard normal scores,
  which are then returned to each task's own distribution through the normal CDF
  and that task's inverse CDF. The previous code applied the factor directly to
  the raw task draws, which the factorization does not support because it
  presumes unit-variance inputs: on the bundled `building_project` data a target
  correlation of 0.20 came out as 0.10, 0.45 came out as 0.59, and the mean total
  inflated from 71.7 to 100.7 weeks. Correlated results now match the target
  matrix to within Monte Carlo error, preserve every marginal distribution
  exactly, and agree with the analytic correlated variance from `smm()`. The
  accompanying warning about marginal-mean distortion has been removed. Results
  from correlated `mcs()` calls will differ from earlier versions; the
  independent path is unchanged.
- **AI integration is now MCP-only.** Removed the natural-language chat agent
  (`pra_chat()`), the Shiny application (`pra_app()`), the slash-command
  interface, and the RAG knowledge base functions (`build_knowledge_base()`,
  `add_documents()`, `retrieve_context()`).
- AI agents now drive PRA through the Model Context Protocol via
  `pra_mcp_server()`, complemented by bundled Agent Skills (`SKILL.md` files)
  under `inst/skills/`.
- Dropped the optional `ragnar`, `shiny`, `shinychat`, `bslib`, `vitals`, and
  `mockr` dependencies. Added `corrplot`, `igraph`, `networkD3`, `devtools`,
  `remotes`, and `mcptools` to Suggests.
- **New (experimental) probabilistic network module:** `prob_net()`,
  `prob_net_sim()`, `prob_net_learn()`, and `prob_net_update()` model project
  risks as a network of discrete and continuous nodes — including conditional
  and aggregate distributions — with simulation, Bayesian updating, and
  learning over the graph. The API may still evolve in future versions.
- **Probabilistic networks (breaking):** the `links` of a `prob_net()` are now
  load-bearing rather than decorative. `prob_net()` requires the edges to match
  the dependencies the distributions declare, rejects a graph that disagrees
  with its distributions, and requires the nodes to be supplied in a topological
  order (which also guarantees acyclicity). `prob_net_update()` re-validates
  after applying changes, so removing the edge into a conditional node must be
  accompanied by a new distribution for that node — an intervention now has to
  sever a dependency in both the graph and the distribution list. The
  `adjacency_matrix` is now directed, with a 1 in `[source, target]` for each
  edge, where it was previously symmetric. Networks that were already
  self-consistent are unaffected, and simulation results are unchanged.
- **Bayesian risk (breaking):** `risk_prob()` and `risk_post_prob()` now combine
  multiple independent causes with a noisy-OR, so the result always lies in
  `[0, 1]`, the posterior is on the same scale as the prior, and observing an
  aggravating cause raises the posterior. Single-cause results are unchanged.
- **Sensitivity analysis (breaking):** `sensitivity()` no longer returns a
  constant value for every task when no correlation matrix is supplied. Each
  task's index is now that task's own variance plus its covariance with all
  other tasks, expressed as a proportion of total project variance —
  differentiating tasks by actual contribution and summing to 1 across all
  tasks. Previously, independent-task results were always 1.0 regardless of
  variance, which was a bug.
- Added the `building_project` example dataset: a mid-rise commercial building
  used to demonstrate the full workflow (MCS, SMM, EVM, Bayesian risk, DSM).
- Vignettes have been removed from the package and migrated to a companion
  Quarto book, alongside a new Journal of Statistical Software paper under
  `inst/paper/pra-jss/`.
- Package license changed from CC BY 4.0 to MIT + file LICENSE.

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