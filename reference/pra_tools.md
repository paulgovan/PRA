# Create PRA Tool Definitions for LLM Agent

Creates a list of ellmer tool objects that wrap PRA's exported functions
for use with an LLM agent. Each tool includes a description that helps
the LLM select the appropriate analysis method and properly format
parameters.

## Usage

``` r
pra_tools()
```

## Value

A list of ellmer tool objects.

## Details

Tool wrappers handle serialization between the LLM (JSON strings) and R
(lists, matrices, data.frames). Complex inputs like task distribution
lists and correlation matrices are accepted as JSON strings and
deserialized internally.

Large output vectors (e.g., Monte Carlo simulation samples) are
summarized to mean, sd, and key percentiles rather than returning the
full vector to the LLM. The full results are stored in the package
environment for use by downstream tools (e.g., contingency analysis
needs the full distribution).

Tool results carry rich HTML display with inline plots via
[`ellmer::ContentToolResult`](https://ellmer.tidyverse.org/reference/Content.html)
for MCP clients that render it, and degrade gracefully to plain text
otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
# The tool set is served to MCP clients by pra_mcp_server().
tools <- pra_tools()
pra_mcp_server()
} # }
```
