---
name: pra-learning-curves
description: >
  Fit sigmoidal (S-curve) learning curves and forecast future values with the
  PRA package. Use when a user has historical time/completion (or unit/cost)
  data showing slow start, rapid acceleration, and plateau, and wants a fitted
  model plus predictions with confidence intervals.
---

# When to use

The user has historical `x` (time or unit number) and `y` (completion, cost,
etc.) data and wants to model the learning curve and project it forward.

# MCP tool

`fit_and_predict_sigmoidal_tool(x_json, y_json, model_type, predict_x_json,
conf_level)` fits the model with nonlinear least squares
(Levenberg–Marquardt) and returns fitted coefficients plus predictions.

- `x_json`: JSON array of x values, e.g. `[1,2,3,4,5,6,7,8,9,10]`.
- `y_json`: JSON array of y values, e.g. `[5,15,40,60,70,75,80,85,90,95]`.
- `model_type`: `"pearl"`, `"gompertz"`, or `"logistic"`.
- `predict_x_json`: x values to forecast at; omit to predict at the original x.
- `conf_level`: e.g. `0.95` for 95% prediction intervals; omit for none.

# Choosing a model

- **Pearl**: symmetric S-curve; growth and saturation balanced.
- **Gompertz**: asymmetric — slow initial growth, rapid mid-phase acceleration.
- **Logistic**: growth from a known initial value.

Fit all three and compare residuals to select the best fit; use confidence
intervals to gauge prediction uncertainty (bands widen as extrapolation extends
beyond the observed range).

# References

- ICEAA Learning Curve Analysis Guide.
- DAU Learning Curve Workshop materials.
