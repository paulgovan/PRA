## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(PRA)

## -----------------------------------------------------------------------------
data <- data.frame(time = 1:9, completion = c(5, 15, 40, 60, 70, 75, 80, 85, 90))

## -----------------------------------------------------------------------------
fit <- fit_sigmoidal(data, "time", "completion", "logistic")

## -----------------------------------------------------------------------------
predictions <- predict_sigmoidal(fit, seq(min(data$time), max(data$time) + 1,
  length.out = 100), "logistic")

## ----warning=FALSE------------------------------------------------------------
p <- ggplot2::ggplot(data, ggplot2::aes_string(x = "time", y = "completion")) +
  ggplot2::geom_point() +
  ggplot2::geom_line(data = predictions, ggplot2::aes(x = x, y = pred), color = "red") +
  ggplot2::labs(title = "Fitted Logistic Model", x = "time", y = "completion %") + 
  ggplot2::theme_minimal()
p

