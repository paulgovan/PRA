# Sample data for testing
data <- data.frame(time = 1:10, completion = c(5, 15, 40, 60, 70, 75, 80, 85, 90, 95))

test_that("fit_sigmoidal returns a valid model for logistic type", {
  fit <- fit_sigmoidal(data, "time", "completion", "logistic")
  expect_s3_class(fit, "nls")
})

test_that("fit_sigmoidal returns a valid model for pearl type", {
  fit <- fit_sigmoidal(data, "time", "completion", "pearl")
  expect_s3_class(fit, "nls")
})

test_that("fit_sigmoidal returns a valid model for gompertz type", {
  fit <- fit_sigmoidal(data, "time", "completion", "gompertz")
  expect_s3_class(fit, "nls")
})

test_that("fit_sigmoidal stops with an invalid model type", {
  expect_error(fit_sigmoidal(data, "time", "completion", "invalid_type"), "Invalid model type. Choose 'pearl', 'gompertz', or 'logistic'.")
})

test_that("predict_sigmoidal returns a data frame with predictions for logistic type", {
  fit <- fit_sigmoidal(data, "time", "completion", "logistic")
  predictions <- predict_sigmoidal(fit, seq(min(data$time), max(data$time), length.out = 100), "logistic")
  expect_s3_class(predictions, "data.frame")
  expect_true(all(c("x", "pred") %in% names(predictions)))
})

test_that("predict_sigmoidal returns a data frame with predictions for pearl type", {
  fit <- fit_sigmoidal(data, "time", "completion", "pearl")
  predictions <- predict_sigmoidal(fit, seq(min(data$time), max(data$time), length.out = 100), "pearl")
  expect_s3_class(predictions, "data.frame")
  expect_true(all(c("x", "pred") %in% names(predictions)))
})

test_that("predict_sigmoidal returns a data frame with predictions for gompertz type", {
  fit <- fit_sigmoidal(data, "time", "completion", "gompertz")
  predictions <- predict_sigmoidal(fit, seq(min(data$time), max(data$time), length.out = 100), "gompertz")
  expect_s3_class(predictions, "data.frame")
  expect_true(all(c("x", "pred") %in% names(predictions)))
})

test_that("predict_sigmoidal stops with an invalid model type", {
  fit <- fit_sigmoidal(data, "time", "completion", "logistic")
  expect_error(predict_sigmoidal(fit, seq(min(data$time), max(data$time), length.out = 100), "invalid_type"), "Invalid model type. Choose 'pearl', 'gompertz', or 'logistic'.")
})
