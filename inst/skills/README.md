# PRA Agent Skills

These are [Agent Skills](https://modelcontextprotocol.io) that document when and
how an AI agent should call PRA's analytical tools. They are designed to pair
with the PRA MCP server (`pra_mcp_server()`), which serves the same tools that
`pra_tools()` defines.

Each subdirectory contains a `SKILL.md` with YAML frontmatter (`name`,
`description`) and instructions:

| Skill | Covers | Primary MCP tools |
|---|---|---|
| `pra-overview` | Routing / entry point | (directs to the tools below) |
| `pra-monte-carlo` | Schedule/cost uncertainty | `mcs_tool`, `smm_tool` |
| `pra-sensitivity-contingency` | Reserves & risk drivers | `contingency_tool`, `sensitivity_tool` |
| `pra-earned-value` | Performance & forecasting | `evm_analysis_tool` |
| `pra-bayesian-risk` | Risk probability & cost | `risk_prob_tool`, `risk_post_prob_tool`, `cost_pdf_tool`, `cost_post_pdf_tool` |
| `pra-learning-curves` | S-curve fitting/forecasts | `fit_and_predict_sigmoidal_tool` |
| `pra-dsm` | Task dependency structure | `parent_dsm_tool`, `grandparent_dsm_tool` |

## Using the skills with the MCP server

Register the server with an MCP-compatible client, then make the skills
available to the agent. For Claude Code:

```sh
claude mcp add -s project pra -- Rscript -e "PRA::pra_mcp_server()"
```

The skill files can be copied to (or referenced from) your agent's skills
directory. Locate the installed copies with:

```r
system.file("skills", package = "PRA")
```
