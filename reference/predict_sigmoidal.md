# Predict a Sigmoidal Function Using Fitted Model.

This function predicts values using a fitted sigmoidal model (Pearl,
Gompertz, or Logistic) over a specified range of time values.

## Usage

``` r
predict_sigmoidal(fit, x_range, model_type, conf_level = NULL)
```

## Arguments

- fit:

  A list containing the results of a sigmoidal model.

- x_range:

  A vector of time values for the prediction.

- model_type:

  The type of model (Pearl, Gompertz, or Logistic) for the prediction.

- conf_level:

  Optional confidence level for confidence bounds (e.g., 0.95 for 95%).
  If NULL (default), no confidence bounds are computed.

## Value

The function returns a data frame containing the time (x), predicted
values (pred), and optionally lower (lwr) and upper (upr) confidence
bounds.

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for
engineering and construction project risk management. No. 172534. Cham,
Switzerland: Springer, 2020.

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
