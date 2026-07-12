---
name: pra-overview
description: >
  Route a project risk analysis request to the right PRA tool. Use this as the
  entry point whenever a user asks about project cost/schedule uncertainty,
  earned value, risk probabilities, learning curves, or task dependencies and
  you are unsure which PRA capability applies. Points to the method-specific
  skills and the underlying MCP tools served by pra_mcp_server().
---

# What PRA offers

The PRA R package exposes its analytical methods as tools over the Model
Context Protocol via `pra_mcp_server()`. Once the server is registered, an
agent can call these tools directly. Each analytical area also has a dedicated
skill with fuller guidance.

# Choosing the right tool

| The user has... | Use MCP tool | Skill |
|---|---|---|
| Task distributions (normal/triangular/uniform), wants total cost/duration | `mcs_tool` | `pra-monte-carlo` |
| Only task means + variances, wants a fast estimate | `smm_tool` | `pra-monte-carlo` |
| Monte Carlo results, wants a reserve buffer | `contingency_tool` | `pra-sensitivity-contingency` |
| Task distributions, wants the biggest risk drivers | `sensitivity_tool` | `pra-sensitivity-contingency` |
| BAC + schedule + actual costs, wants performance/forecasts | `evm_analysis_tool` | `pra-earned-value` |
| Root-cause probabilities, wants risk probability | `risk_prob_tool` / `risk_post_prob_tool` | `pra-bayesian-risk` |
| Risk cost impacts, wants a cost distribution | `cost_pdf_tool` / `cost_post_pdf_tool` | `pra-bayesian-risk` |
| Historical time/completion data, wants a forecast curve | `fit_and_predict_sigmoidal_tool` | `pra-learning-curves` |
| A resource–task (and optional risk–resource) matrix | `parent_dsm_tool` / `grandparent_dsm_tool` | `pra-dsm` |

# Common multi-step workflows

1. **Schedule/cost risk**: `mcs_tool` → `contingency_tool` + `sensitivity_tool`
2. **EVM analysis**: `evm_analysis_tool` (computes PV, EV, AC, SV, CV, SPI, CPI,
   EAC, ETC, VAC, TCPI in one call)
3. **Bayesian prior → posterior**: `risk_prob_tool` → `cost_pdf_tool` →
   [observe causes] → `risk_post_prob_tool` → `cost_post_pdf_tool`
4. **Learning curve**: `fit_and_predict_sigmoidal_tool`

# Conventions

- All array/matrix arguments are passed as JSON strings (e.g.
  `task_dists_json`, `cor_mat_json`). Pass `"null"` (or omit) an optional
  correlation matrix to treat tasks as independent.
- Never fabricate numerical results — call the tool.
- The probabilistic-network functions (`prob_net`, `prob_net_sim`,
  `prob_net_learn`, `prob_net_update`) are available in the R package but are
  not exposed as MCP tools; use them from an R session.
