# Start a PRA MCP Server

Launches an MCP server that exposes all PRA analytical tools via the
Model Context Protocol. Once running, Claude Desktop, Claude Code, or
any MCP-compatible client can call PRA functions (Monte Carlo
simulation, EVM, Bayesian risk, learning curves, DSM, etc.) as native
tools.

## Usage

``` r
pra_mcp_server()
```

## Value

Called for its side effect (starts the MCP server process). Does not
return under normal operation.

## Details

The server communicates over stdio by default, which is the standard
transport for local MCP servers. It reuses the same tool definitions
from
[`pra_tools()`](https://paulgovan.github.io/PRA/reference/pra_tools.md),
so any tool updates are automatically reflected.

## Examples

``` r
if (FALSE) { # \dontrun{
# Start the server from an R session
pra_mcp_server()

# Or launch directly from the terminal (for use in Claude Code / Desktop):
# Rscript -e "PRA::pra_mcp_server()"
} # }
```
