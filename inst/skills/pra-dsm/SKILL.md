---
name: pra-dsm
description: >
  Quantify structural coupling between project tasks through shared resources
  and risks using the PRA package's Design Structure Matrices. Use when a user
  provides a resource–task matrix (and optionally a risk–resource matrix) and
  wants to see which task pairs are coupled and therefore tend to fail together.
---

# When to use

The user has a binary matrix mapping resources to tasks (and optionally risks to
resources) and wants to identify coupled task pairs — the structural pathways
through which disruptions and risks propagate.

# MCP tools

- `parent_dsm_tool(matrix_json)` — the **Parent DSM**, derived from the
  resource–task matrix **S** (rows = resources, columns = tasks) as
  `P = Sᵀ S`. Off-diagonal `P[j,k]` counts resources shared between tasks j and
  k. `matrix_json` is a JSON 2-D array, e.g.
  `[[1,0,1,0],[0,1,0,1],[1,0,1,1]]`.
- `grandparent_dsm_tool(s_matrix_json, r_matrix_json)` — the **Grandparent
  DSM**, which adds a risk layer via the risk–resource matrix **R**. Off-diagonal
  `G[j,k]` counts risks shared between tasks j and k through the resource chain.
  - `s_matrix_json`: resource–task matrix S (resources × tasks).
  - `r_matrix_json`: risk–resource matrix R (risks × resources).

# Interpreting results

Task pairs with high off-diagonal values are strongly coupled: in the Parent DSM
through shared resources, in the Grandparent DSM through shared risk exposure.
These pairs are prime candidates for contingency buffering or resource
decoupling, and pair naturally with a Monte Carlo correlation structure
(`pra-monte-carlo`).

# Related (R-only)

For distribution-level propagation along the causal chain from risks to total
project cost, the package also provides probabilistic networks (`prob_net`,
`prob_net_sim`, `prob_net_learn`, `prob_net_update`). These are available from
an R session but are not exposed as MCP tools.

# References

- Steward (1981), *Systems Analysis and Management*.
- Browning (2001), Applying the DSM to System Decomposition and Integration.
- Govan and Damnjanovic (2016, 2020), resource-based / structural-network
  measures for project risk.
