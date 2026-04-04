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
