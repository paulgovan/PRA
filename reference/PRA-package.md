# PRA: Project Risk Analysis

Data analysis for Project Risk Management via the Second Moment Method,
Monte Carlo Simulation, Contingency Analysis, Sensitivity Analysis,
Earned Value Management, Learning Curves, Bayesian Methods, and more.

## Key modules

- **Monte Carlo Simulation**
  ([`mcs()`](https://paulgovan.github.io/PRA/reference/mcs.md)):

  Propagates schedule or cost uncertainty through a triangular
  distribution model using `mc2d`. Returns an S3 object with a `print`
  method.

- **Second Moment Method**
  ([`smm()`](https://paulgovan.github.io/PRA/reference/smm.md)):

  Analytical first- and second-moment propagation of uncertainty without
  simulation. Returns an S3 object with a `print` method.

- **Earned Value Management**
  ([`pv()`](https://paulgovan.github.io/PRA/reference/pv.md),
  [`ev()`](https://paulgovan.github.io/PRA/reference/ev.md),
  [`ac()`](https://paulgovan.github.io/PRA/reference/ac.md),
  [`sv()`](https://paulgovan.github.io/PRA/reference/sv.md),
  [`cv()`](https://paulgovan.github.io/PRA/reference/cv.md),
  [`spi()`](https://paulgovan.github.io/PRA/reference/spi.md),
  [`cpi()`](https://paulgovan.github.io/PRA/reference/cpi.md),
  [`eac()`](https://paulgovan.github.io/PRA/reference/eac.md),
  [`etc()`](https://paulgovan.github.io/PRA/reference/etc.md),
  [`tcpi()`](https://paulgovan.github.io/PRA/reference/tcpi.md),
  [`vac()`](https://paulgovan.github.io/PRA/reference/vac.md)):

  Full suite of EVM performance metrics and forecasting functions.

- **Contingency Analysis**
  ([`contingency()`](https://paulgovan.github.io/PRA/reference/contingency.md)):

  Derives cost or schedule contingency from simulation output at a
  user-specified confidence level.

- **Sensitivity Analysis**
  ([`sensitivity()`](https://paulgovan.github.io/PRA/reference/sensitivity.md)):

  Ranks risk drivers by their contribution to overall project
  uncertainty.

- **Learning Curves**
  ([`fit_sigmoidal()`](https://paulgovan.github.io/PRA/reference/fit_sigmoidal.md),
  [`predict_sigmoidal()`](https://paulgovan.github.io/PRA/reference/predict_sigmoidal.md),
  [`plot_sigmoidal()`](https://paulgovan.github.io/PRA/reference/plot_sigmoidal.md)):

  Fits Pearl, Gompertz, or Logistic sigmoidal growth models to
  cumulative cost or progress data using nonlinear least squares
  (`minpack.lm`).

- **Bayesian Risk Inference**
  ([`risk_prob()`](https://paulgovan.github.io/PRA/reference/risk_prob.md),
  [`risk_post_prob()`](https://paulgovan.github.io/PRA/reference/risk_post_prob.md)):

  Beta-Binomial conjugate updating for risk event probabilities.

- **Correlation Matrices**
  ([`cor_matrix()`](https://paulgovan.github.io/PRA/reference/cor_matrix.md)):

  Constructs valid positive-definite correlation matrices for use in
  multivariate simulations.

- **Design Structure Matrix**
  ([`parent_dsm()`](https://paulgovan.github.io/PRA/reference/parent_dsm.md),
  [`grandparent_dsm()`](https://paulgovan.github.io/PRA/reference/grandparent_dsm.md)):

  Derives direct (parent) and indirect (grandparent) dependency
  structure matrices from a binary adjacency matrix.

## References

Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for
engineering and construction project risk management. No. 172534. Cham,
Switzerland: Springer, 2020.

## See also

Useful links:

- <https://paulgovan.github.io/PRA/>

- <https://github.com/paulgovan/PRA>

- Report bugs at <https://github.com/paulgovan/PRA/issues>

## Author

Paul Govan <paul.govan2@gmail.com> (ORCID:
[0000-0002-1821-8492](https://orcid.org/0000-0002-1821-8492))
