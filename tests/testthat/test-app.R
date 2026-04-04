#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*

test_that("pra_shiny_app creates a Shiny app object", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("bslib")
  skip_if_not_installed("ellmer")
  skip_if_not_installed("shinychat")
  app <- PRA:::pra_shiny_app()
  expect_s3_class(app, "shiny.appobj")
})

test_that("pra_shiny_app accepts model parameter", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("bslib")
  skip_if_not_installed("ellmer")
  skip_if_not_installed("shinychat")
  app <- PRA:::pra_shiny_app(model = "qwen2.5")
  expect_s3_class(app, "shiny.appobj")
})

test_that("pra_shiny_app accepts rag parameter", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("bslib")
  skip_if_not_installed("ellmer")
  skip_if_not_installed("shinychat")
  app <- PRA:::pra_shiny_app(rag = FALSE)
  expect_s3_class(app, "shiny.appobj")
})

test_that("pra_app function exists and has correct parameters", {
  expect_true(is.function(pra_app))
  args <- formals(pra_app)
  expect_true("model" %in% names(args))
  expect_true("rag" %in% names(args))
  expect_true("embed_model" %in% names(args))
  expect_true("port" %in% names(args))
  expect_true("launch.browser" %in% names(args))
})

test_that("pra_app default model is llama3.2", {
  args <- formals(pra_app)
  expect_equal(args$model, "llama3.2")
})

test_that("pra_app default rag is TRUE", {
  args <- formals(pra_app)
  expect_true(args$rag)
})

test_that("get_ollama_models returns character vector", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("bslib")
  skip_if_not_installed("ellmer")
  skip_if_not_installed("shinychat")
  models <- PRA:::get_ollama_models()
  expect_type(models, "character")
  expect_true(length(models) >= 1)
})
