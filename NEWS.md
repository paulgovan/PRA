# NEWS

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