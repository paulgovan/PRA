#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*

test_that("knowledge files exist in inst/knowledge", {
  knowledge_dir <- system.file("knowledge", package = "PRA")
  # If running in dev mode, use inst/ directly

  if (knowledge_dir == "") {
    knowledge_dir <- file.path("../../inst/knowledge")
  }
  expect_true(dir.exists(knowledge_dir))
  md_files <- list.files(knowledge_dir, pattern = "\\.md$")
  expect_true(length(md_files) >= 6)
  expected_files <- c(
    "mcs_methods.md", "evm_standards.md", "bayesian_risk.md",
    "learning_curves.md", "sensitivity_contingency.md", "pra_functions.md"
  )
  for (f in expected_files) {
    expect_true(f %in% md_files, info = paste("Missing knowledge file:", f))
  }
})

test_that("knowledge files are non-empty", {
  knowledge_dir <- system.file("knowledge", package = "PRA")
  if (knowledge_dir == "") {
    knowledge_dir <- file.path("../../inst/knowledge")
  }
  md_files <- list.files(knowledge_dir, pattern = "\\.md$", full.names = TRUE)
  for (f in md_files) {
    content <- readLines(f, warn = FALSE)
    expect_true(length(content) > 10,
      info = paste("File too short:", basename(f))
    )
  }
})

test_that("build_knowledge_base requires ragnar", {
  skip_if_not_installed("ragnar")
  skip_if_not_installed("ellmer")
  # We can't fully test without Ollama running, but we can check the function exists

  expect_true(is.function(build_knowledge_base))
})

test_that("retrieve_context requires ragnar", {
  skip_if_not_installed("ragnar")
  expect_true(is.function(retrieve_context))
})

# ============================================================================
# RAG Retrieval Quality Tests (require Ollama)
# ============================================================================

test_that("RAG retrieves correct source for MCS queries", {
  skip_if_not_installed("ragnar")
  skip_if_not_installed("ellmer")
  skip_on_cran()
  # Skip if Ollama isn't running
  ollama_ok <- tryCatch({
    con <- url("http://localhost:11434/api/tags", open = "rb")
    on.exit(close(con))
    TRUE
  }, error = function(e) FALSE)
  skip_if(!ollama_ok, "Ollama not running")

  store <- build_knowledge_base()
  chunks <- retrieve_context(store, "How do I run a Monte Carlo simulation?", top_k = 3)
  expect_true(length(chunks) > 0)
  # At least one chunk should come from mcs_methods.md
  expect_true(any(grepl("mcs_methods\\.md", chunks)),
    info = paste("Sources:", paste(chunks, collapse = " | ")))
})

test_that("RAG retrieves correct source for EVM queries", {
  skip_if_not_installed("ragnar")
  skip_if_not_installed("ellmer")
  skip_on_cran()
  ollama_ok <- tryCatch({
    con <- url("http://localhost:11434/api/tags", open = "rb")
    on.exit(close(con))
    TRUE
  }, error = function(e) FALSE)
  skip_if(!ollama_ok, "Ollama not running")

  store <- build_knowledge_base()
  chunks <- retrieve_context(store, "What is earned value management and how is CPI calculated?", top_k = 3)
  expect_true(length(chunks) > 0)
  expect_true(any(grepl("evm_standards\\.md", chunks)),
    info = paste("Sources:", paste(chunks, collapse = " | ")))
})

test_that("RAG retrieves correct source for Bayesian queries", {
  skip_if_not_installed("ragnar")
  skip_if_not_installed("ellmer")
  skip_on_cran()
  ollama_ok <- tryCatch({
    con <- url("http://localhost:11434/api/tags", open = "rb")
    on.exit(close(con))
    TRUE
  }, error = function(e) FALSE)
  skip_if(!ollama_ok, "Ollama not running")

  store <- build_knowledge_base()
  chunks <- retrieve_context(store, "How does Bayesian risk analysis work for root cause analysis?", top_k = 3)
  expect_true(length(chunks) > 0)
  expect_true(any(grepl("bayesian_risk\\.md", chunks)),
    info = paste("Sources:", paste(chunks, collapse = " | ")))
})

test_that("RAG retrieves correct source for learning curve queries", {
  skip_if_not_installed("ragnar")
  skip_if_not_installed("ellmer")
  skip_on_cran()
  ollama_ok <- tryCatch({
    con <- url("http://localhost:11434/api/tags", open = "rb")
    on.exit(close(con))
    TRUE
  }, error = function(e) FALSE)
  skip_if(!ollama_ok, "Ollama not running")

  store <- build_knowledge_base()
  chunks <- retrieve_context(store, "What sigmoidal learning curve models are available?", top_k = 3)
  expect_true(length(chunks) > 0)
  expect_true(any(grepl("learning_curves\\.md", chunks)),
    info = paste("Sources:", paste(chunks, collapse = " | ")))
})

test_that("RAG retrieves correct source for sensitivity queries", {
  skip_if_not_installed("ragnar")
  skip_if_not_installed("ellmer")
  skip_on_cran()
  ollama_ok <- tryCatch({
    con <- url("http://localhost:11434/api/tags", open = "rb")
    on.exit(close(con))
    TRUE
  }, error = function(e) FALSE)
  skip_if(!ollama_ok, "Ollama not running")

  store <- build_knowledge_base()
  chunks <- retrieve_context(store, "How is contingency reserve calculated from simulation results?", top_k = 3)
  expect_true(length(chunks) > 0)
  expect_true(any(grepl("sensitivity_contingency\\.md", chunks)),
    info = paste("Sources:", paste(chunks, collapse = " | ")))
})

# ============================================================================
# Knowledge coverage audit
# ============================================================================

test_that("each tool domain has a corresponding knowledge file", {
  # Map tool domains to expected knowledge files
  tool_knowledge_map <- list(
    mcs = "mcs_methods.md",
    smm = "mcs_methods.md",
    evm = "evm_standards.md",
    bayesian = "bayesian_risk.md",
    learning = "learning_curves.md",
    sensitivity = "sensitivity_contingency.md",
    contingency = "sensitivity_contingency.md"
  )

  knowledge_dir <- system.file("knowledge", package = "PRA")
  if (knowledge_dir == "") knowledge_dir <- file.path("../../inst/knowledge")
  md_files <- list.files(knowledge_dir, pattern = "\\.md$")

  for (domain in names(tool_knowledge_map)) {
    expected_file <- tool_knowledge_map[[domain]]
    expect_true(expected_file %in% md_files,
      info = paste("Missing knowledge coverage for", domain, ":", expected_file))
  }
})
