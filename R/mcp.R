#' Start a PRA MCP Server
#'
#' Launches an MCP server that exposes all PRA analytical tools via the Model
#' Context Protocol. Once running, Claude Desktop, Claude Code, or any
#' MCP-compatible client can call PRA functions (Monte Carlo simulation, EVM,
#' Bayesian risk, learning curves, DSM, etc.) as native tools.
#'
#' The server communicates over stdio by default, which is the standard
#' transport for local MCP servers. It reuses the same tool definitions from
#' [pra_tools()], so any tool updates are automatically reflected. The bundled
#' Agent Skills in `inst/skills/` document when and how an agent should call
#' each tool.
#'
#' @return Called for its side effect (starts the MCP server process). Does
#'   not return under normal operation.
#'
#' @examples
#' \dontrun{
#' # Start the server from an R session
#' pra_mcp_server()
#'
#' # Or launch directly from the terminal (for use in Claude Code / Desktop):
#' # Rscript -e "PRA::pra_mcp_server()"
#' }
#'
#' @export
pra_mcp_server <- function() {
  if (!requireNamespace("mcptools", quietly = TRUE)) {
    stop("Package 'mcptools' is required. Install with: install.packages('mcptools')")
  }
  mcptools::mcp_server(tools = pra_tools())
}
