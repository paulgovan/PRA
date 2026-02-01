# Fit a Sigmoidal Model to Data.

This function fits a sigmoidal model (Pearl, Gompertz, or Logistic) to
the provided data.

## Usage

``` r
fit_sigmoidal(data, x_col, y_col, model_type)
```

## Arguments

- data:

  A data frame containing the time (x_col) and completion (y_col)
  vectors.

- x_col:

  The name of the time vector.

- y_col:

  The name of the completion vector.

- model_type:

  The name of the sigmoidal model (Pearl, Gompertz, or Logistic).

## Value

The function returns a list of results for the sigmoidal model.

## Examples

``` r
# Set up a data frame of time and completion percentage data
data <- data.frame(time = 1:10, completion = c(5, 15, 40, 60, 70, 75, 80, 85, 90, 95))

# Fit a logistic model to the data.
fit <- fit_sigmoidal(data, "time", "completion", "logistic")

# Use the model to predict future completion times.
predictions <- predict_sigmoidal(fit, seq(min(data$time), max(data$time),
  length.out = 100
), "logistic")

# Predict with 95% confidence bounds
predictions_ci <- predict_sigmoidal(fit, seq(min(data$time), max(data$time),
  length.out = 100
), "logistic", conf_level = 0.95)
```
