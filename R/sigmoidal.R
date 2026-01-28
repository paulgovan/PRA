#' Fit a Sigmoidal Model.
#'
#' @param data A data frame containing the time (x_col) and completion (y_col) vectors.
#' @param x_col The name of the time vector.
#' @param y_col The name of the completion vector.
#' @param model_type The name of the sigmoidal model (Pearl, Gompertz, or Logistic).
#' @return The function returns a list of results for the sigmoidal model.
#' @examples
#' # Set up a data frame of time and completion percentage data
#' data <- data.frame(time = 1:10, completion = c(5, 15, 40, 60, 70, 75, 80, 85, 90, 95))
#'
#' # Fit a logistic model to the data.
#' fit <- fit_sigmoidal(data, "time", "completion", "logistic")
#'
#' # Use the model to predict future completion times.
#' predictions <- predict_sigmoidal(fit, seq(min(data$time), max(data$time),
#'   length.out = 100
#' ), "logistic")
#'
#' # Plot the results.
#' p <- ggplot2::ggplot(data, ggplot2::aes_string(x = "time", y = "completion")) +
#'   ggplot2::geom_point() +
#'   ggplot2::geom_line(data = predictions, ggplot2::aes(x = x, y = pred), color = "red") +
#'   ggplot2::labs(title = "Fitted Logistic Model", x = "time", y = "completion %") +
#'   ggplot2::theme_minimal()
#' p
#' @import minpack.lm
#' @importFrom stats median
#' @export

# Fit a Sigmoidal Model
fit_sigmoidal <- function(data, x_col, y_col, model_type) {
  x <- data[[x_col]]
  y <- data[[y_col]]

  # Pearl Sigmoidal Model
  pearl <- function(x, K, r, t0) {
    K / (1 + exp(-r * (x - t0)))
  }

  # Gompertz Sigmoidal Model
  gompertz <- function(x, A, b, c) {
    A * exp(-b * exp(-c * x))
  }

  # Logistic Sigmoidal Model
  logistic <- function(x, K, r, t0) {
    K / (1 + exp(-r * (x - t0)))
  }

  if (model_type == "pearl") {
    fit <- minpack.lm::nlsLM(y ~ pearl(x, K, r, t0), start = list(K = max(y), r = 0.1, t0 = stats::median(x)))
  } else if (model_type == "gompertz") {
    fit <- minpack.lm::nlsLM(y ~ gompertz(x, A, b, c), start = list(A = max(y), b = 1, c = 0.1))
  } else if (model_type == "logistic") {
    fit <- minpack.lm::nlsLM(y ~ logistic(x, K, r, t0), start = list(K = max(y), r = 0.1, t0 = stats::median(x)))
  } else {
    stop("Invalid model type. Choose 'pearl', 'gompertz', or 'logistic'.")
  }

  fit
}

#' Predict a Sigmoidal Function.
#'
#' @param fit A list containing the results of a sigmoidal model.
#' @param x_range A vector of time values for the prediction.
#' @param model_type The type of model (Pearl, Gompertz, or Logistic) for the prediction.
#' @return The function returns a table of results containing the time and predicted values.
#' @examples
#' # Set up a data frame of time and completion percentage data
#' data <- data.frame(time = 1:10, completion = c(5, 15, 40, 60, 70, 75, 80, 85, 90, 95))
#'
#' # Fit a logistic model to the data.
#' fit <- fit_sigmoidal(data, "time", "completion", "logistic")
#'
#' # Use the model to predict future completion times.
#' predictions <- predict_sigmoidal(fit, seq(min(data$time), max(data$time),
#'   length.out = 100
#' ), "logistic")
#'
#' # Plot the results.
#' p <- ggplot2::ggplot(data, ggplot2::aes_string(x = "time", y = "completion")) +
#'   ggplot2::geom_point() +
#'   ggplot2::geom_line(data = predictions, ggplot2::aes(x = x, y = pred), color = "red") +
#'   ggplot2::labs(title = "Fitted Logistic Model", x = "time", y = "completion %") +
#'   ggplot2::theme_minimal()
#' p
#' @importFrom stats predict
#' @export
# Predict a Sigmoidal Function
predict_sigmoidal <- function(fit, x_range, model_type) {
  new_data <- data.frame(x = x_range)

  if (model_type == "pearl") {
    new_data$pred <- stats::predict(fit, newdata = new_data)
    # confint <- predict(fit, newdata = new_data, interval = "confidence")
  } else if (model_type == "gompertz") {
    new_data$pred <- stats::predict(fit, newdata = new_data)
    # confint <- predict(fit, newdata = new_data, interval = "confidence")
  } else if (model_type == "logistic") {
    new_data$pred <- stats::predict(fit, newdata = new_data)
    # confint <- predict(fit, newdata = new_data, interval = "confidence")
  } else {
    stop("Invalid model type. Choose 'pearl', 'gompertz', or 'logistic'.")
  }

  new_data <- new_data
  # %>%
  # dplyr::mutate(lwr = confint[, "lwr"],
  # upr = confint[, "upr"])

  new_data
}
