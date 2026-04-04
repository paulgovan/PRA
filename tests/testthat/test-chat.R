#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*

test_that("pra_system_prompt returns a non-empty string", {
  prompt <- PRA:::pra_system_prompt()
  expect_type(prompt, "character")
  expect_true(nchar(prompt) > 50)
  # Should mention key tool names
  expect_true(grepl("mcs_tool", prompt))
  expect_true(grepl("evm_analysis_tool", prompt))
  expect_true(grepl("risk_prob_tool", prompt))
  expect_true(grepl("fit_and_predict_sigmoidal_tool", prompt))
  # Should instruct citation of RAG sources
  expect_true(grepl("cite", prompt, ignore.case = TRUE))
  # Should distinguish conceptual questions from computation
  expect_true(grepl("CONCEPTUAL", prompt))
  expect_true(grepl("NUMERICAL DATA", prompt))
  # Should tell the LLM not to output /commands
  expect_true(grepl("Do not use /commands", prompt, ignore.case = TRUE))
})

test_that("pra_system_prompt is concise for small models", {
  prompt <- PRA:::pra_system_prompt()
  # Should be under 2000 chars
  expect_true(nchar(prompt) < 2000)
})

test_that("pra_chat requires ellmer", {
  skip_if_not_installed("ellmer")
  expect_true(is.function(pra_chat))
})

test_that("pra_chat accepts chat parameter", {
  skip_if_not_installed("ellmer")
  # Function should accept a chat parameter
  args <- formals(pra_chat)
  expect_true("chat" %in% names(args))
  expect_null(args$chat)
})

test_that("pra_chat default model is llama3.2", {
  args <- formals(pra_chat)
  expect_equal(args$model, "llama3.2")
})

test_that("pra_app requires shiny and ellmer", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ellmer")
  skip_if_not_installed("bslib")
  skip_if_not_installed("shinychat")
  expect_true(is.function(pra_app))
})
