#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*

test_that("pra_mcp_server is an exported function", {
  expect_true(is.function(pra_mcp_server))
  expect_length(formals(pra_mcp_server), 0)
})

test_that("pra_mcp_server errors informatively when mcptools is absent", {
  skip_if(requireNamespace("mcptools", quietly = TRUE),
    "mcptools installed; cannot test the missing-dependency path.")
  expect_error(pra_mcp_server(), "mcptools")
})

test_that("pra_mcp_server exposes the PRA tool set via pra_tools()", {
  skip_if_not_installed("ellmer")
  # pra_mcp_server() starts a blocking stdio loop, so we do not call it here;
  # instead we verify the tool set it hands to mcptools::mcp_server() is valid.
  tools <- pra_tools()
  expect_type(tools, "list")
  expect_gt(length(tools), 0)
})
