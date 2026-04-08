# Changelog

## PRA 0.4.0

- **Breaking change**:
  [`parent_dsm()`](https://paulgovan.github.io/PRA/reference/parent_dsm.md)
  and
  [`grandparent_dsm()`](https://paulgovan.github.io/PRA/reference/grandparent_dsm.md)
  now return S3 objects of class “dsm” instead of raw matrices. Access
  the matrix via `result$matrix`.
- **Bug fix**: Corrected the DSM formula to use `t(S) %*% S` (was
  `S %*% t(S)`). The Resource-Task Matrix S has rows = resources and
  columns = tasks, so the correct tasks-by-tasks DSM is `t(S) %*% S`.
- **Bug fix**: Removed incorrect requirement that S must be square.
  Resource-Task matrices are typically rectangular.
- **Bug fix**: Fixed dimension compatibility check in
  [`grandparent_dsm()`](https://paulgovan.github.io/PRA/reference/grandparent_dsm.md)
  to validate `nrow(S) == ncol(R)`.
- New
  [`print.dsm()`](https://paulgovan.github.io/PRA/reference/print.dsm.md)
  and
  [`plot.dsm()`](https://paulgovan.github.io/PRA/reference/plot.dsm.md)
  S3 methods for DSM objects.
- New vignette: “Design Structure Matrices”.
- Enhanced the sigmoidal model with additional features and improved
  parameter recovery tests.
- Updated Bayesian methods with improved documentation and error
  handling.
- Added comprehensive test suite with platform-dependent compatibility
  fixes for CRAN.
- Improved error handling across all functions with robust validations
  for NA, NaN, and Inf values.
- Enhanced overall documentation for better user guidance.

## PRA 0.3.0

CRAN release: 2024-08-20

- Includes new vignettes for several PRA methods.
- New helper function for estimating the correlation matrix for a set of
  variables.
- Minor updates and bug fixes.

## PRA 0.2.0

CRAN release: 2024-07-02

- Minor updates and bug fixes.

## PRA 0.1.0

- Initial CRAN submission.
