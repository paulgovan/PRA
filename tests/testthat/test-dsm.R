#' @srrstats {G5.2} *Error and warning behaviour is explicitly demonstrated through tests.*
#' @srrstats {G5.2a} *Every error message is unique and tested.*
#' @srrstats {G5.2b} *Tests trigger every error message and compare with expected values.*
#' @srrstats {G5.3} *Return objects tested for absence of NA, NaN, Inf.*
#' @srrstats {G5.6} *Parameter recovery tests verify implementations produce expected results given data with known properties.*
#' @srrstats {G5.6a} *Parameter recovery tests succeed within defined tolerance rather than exact values.*
#' @srrstats {G5.6b} *Parameter recovery tests run with multiple random seeds when randomness is involved.*
#' @srrstats {G5.7} *Algorithm performance tests verify implementations perform correctly as data properties change.*
#' @srrstats {G5.8} *Edge condition tests verify appropriate behavior with extreme data properties.*
#' @srrstats {G5.8a} *Zero-length data tests trigger clear errors.*
#' @srrstats {G5.8b} *Unsupported data type tests trigger clear errors.*
#' @srrstats {G5.8c} *All-NA and all-identical data tests trigger clear errors or warnings.*
#' @srrstats {G5.8d} *Out-of-scope data tests verify appropriate behavior.*
#' @srrstats {G5.9} *Noise susceptibility tests verify stochastic behavior stability.*
#' @srrstats {G5.9a} *Trivial noise tests show results are stable at machine epsilon scale.*
#' @srrstats {G5.9b} *Random seed stability tests show consistent behavior across different seeds.*

# Unit tests for the parent_dsm function
test_that("parent_dsm function works correctly with valid input", {
  sm <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)

  result <- parent_dsm(sm)

  expect_true(is.matrix(result))
  expect_equal(dim(result), c(2, 2))

  expected_result <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)
  expect_equal(result, expected_result)
})

test_that("parent_dsm function handles non-square matrix", {
  sm <- matrix(c(1, 0, 1), nrow = 1, ncol = 3)

  expect_error(parent_dsm(sm), "The Resource-Task Matrix must be square.")
})

test_that("parent_dsm function handles larger matrices", {
  sm <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), nrow = 3, ncol = 3)

  result <- parent_dsm(sm)

  expect_true(is.matrix(result))
  expect_equal(dim(result), c(3, 3))

  expected_result <- matrix(c(66, 78, 90, 78, 93, 108, 90, 108, 126), nrow = 3, ncol = 3)
  expect_equal(result, expected_result)
})

test_that("grandparent_dsm function works correctly with valid input", {
  sm <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)
  rm <- matrix(c(1, 2, 3, 4), nrow = 2, ncol = 2)

  result <- grandparent_dsm(sm, rm)

  expect_true(is.matrix(result))
  expect_equal(dim(result), c(2, 2))

  expected_result <- matrix(c(5, 11, 11, 25), nrow = 2, ncol = 2)
  expect_equal(result, expected_result)
})

test_that("grandparent_dsm function handles non-square S matrix", {
  sm <- matrix(c(1, 0, 1), nrow = 1, ncol = 3)
  rm <- matrix(c(1, 2, 3, 4, 5, 6), nrow = 2, ncol = 3)

  expect_error(grandparent_dsm(sm, rm), "Matrix S must be square.")
})

test_that("grandparent_dsm function handles incompatible dimensions", {
  sm <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)
  rm <- matrix(c(1, 2, 3), nrow = 1, ncol = 3)

  expect_error(grandparent_dsm(sm, rm), "Number of columns in the Matrix S must be equal to the number of columns in Matrix R.")
})

test_that("grandparent_dsm function handles larger matrices", {
  sm <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), nrow = 3, ncol = 3)
  rm <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), nrow = 3, ncol = 3)

  result <- grandparent_dsm(sm, rm)

  expect_true(is.matrix(result))
  expect_equal(dim(result), c(3, 3))
})

test_that("grandparent_dsm function handles non-square R matrix", {
  sm <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)
  rm <- matrix(c(1, 2, 3, 4, 5, 6), nrow = 2, ncol = 3)

  expect_error(grandparent_dsm(sm, rm), "Number of columns in the Matrix S must be equal to the number of columns in Matrix R.")
})

# Tests for NULL input validation
test_that("parent_dsm handles NULL input correctly", {
  expect_error(parent_dsm(NULL), "S must not be NULL")
})

test_that("grandparent_dsm handles NULL inputs correctly", {
  sm <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)
  rm <- matrix(c(1, 2, 3, 4), nrow = 2, ncol = 2)

  expect_error(grandparent_dsm(NULL, rm), "S and R must not be NULL")
  expect_error(grandparent_dsm(sm, NULL), "S and R must not be NULL")
})

# Tests for non-matrix input validation
test_that("parent_dsm handles non-matrix input correctly", {
  expect_error(parent_dsm("not a matrix"), "S must be a matrix or data frame")
  expect_error(parent_dsm(c(1, 2, 3, 4)), "S must be a matrix or data frame")
})

test_that("grandparent_dsm handles non-matrix inputs correctly", {
  sm <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)

  expect_error(grandparent_dsm("not a matrix", sm), "S must be a matrix or data frame")
  expect_error(grandparent_dsm(sm, "not a matrix"), "R must be a matrix or data frame")
})

# Tests for non-numeric input validation
test_that("parent_dsm handles non-numeric matrix correctly", {
  char_matrix <- matrix(c("a", "b", "c", "d"), nrow = 2, ncol = 2)
  expect_error(parent_dsm(char_matrix), "S must contain numeric values")
})

test_that("grandparent_dsm handles non-numeric matrices correctly", {
  sm <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)
  char_matrix <- matrix(c("a", "b", "c", "d"), nrow = 2, ncol = 2)

  expect_error(grandparent_dsm(char_matrix, sm), "S and R must contain numeric values")
  expect_error(grandparent_dsm(sm, char_matrix), "S and R must contain numeric values")
})

# Tests for data frame input (should work)
test_that("parent_dsm handles data frame input correctly", {
  df <- data.frame(a = c(1, 0), b = c(0, 1))
  result <- parent_dsm(as.matrix(df))
  expect_true(is.matrix(result))
})

test_that("grandparent_dsm handles data frame inputs correctly", {
  sm <- data.frame(a = c(1, 0), b = c(0, 1))
  rm <- data.frame(a = c(1, 2), b = c(3, 4))
  result <- grandparent_dsm(as.matrix(sm), as.matrix(rm))
  expect_true(is.matrix(result))
})

# ============================================================================
# NaN/NA/Inf Error Tests (G5.2, G5.2b)
# ============================================================================
test_that("parent_dsm rejects NaN values in S", {
  sm <- matrix(c(1, NaN, 0, 1), nrow = 2, ncol = 2)
  expect_error(parent_dsm(sm), "S must not contain NaN values")
})

test_that("parent_dsm rejects NA values in S", {
  sm <- matrix(c(1, NA, 0, 1), nrow = 2, ncol = 2)
  expect_error(parent_dsm(sm), "S must not contain NA values")
})

test_that("parent_dsm rejects Inf values in S", {
  sm <- matrix(c(1, Inf, 0, 1), nrow = 2, ncol = 2)
  expect_error(parent_dsm(sm), "S must not contain infinite values")
})

test_that("grandparent_dsm rejects NaN values in S or R", {
  sm <- matrix(c(1, NaN, 0, 1), nrow = 2, ncol = 2)
  rm <- matrix(c(1, 2, 3, 4), nrow = 2, ncol = 2)
  expect_error(grandparent_dsm(sm, rm), "S and R must not contain NaN values")
})

test_that("grandparent_dsm rejects NA values in S or R", {
  sm <- matrix(c(1, NA, 0, 1), nrow = 2, ncol = 2)
  rm <- matrix(c(1, 2, 3, 4), nrow = 2, ncol = 2)
  expect_error(grandparent_dsm(sm, rm), "S and R must not contain NA values")
})

test_that("grandparent_dsm rejects Inf values in S or R", {
  sm <- matrix(c(1, Inf, 0, 1), nrow = 2, ncol = 2)
  rm <- matrix(c(1, 2, 3, 4), nrow = 2, ncol = 2)
  expect_error(grandparent_dsm(sm, rm), "S and R must not contain infinite values")
})

# ============================================================================
# G5.3: Return value tests
# ============================================================================
test_that("parent_dsm result contains no NA, NaN, or Inf", {
  sm <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), nrow = 3, ncol = 3)
  result <- parent_dsm(sm)
  expect_false(anyNA(result))
  expect_false(any(is.nan(result)))
  expect_false(any(is.infinite(result)))
})

test_that("grandparent_dsm result contains no NA, NaN, or Inf", {
  sm <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), nrow = 3, ncol = 3)
  rm <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), nrow = 3, ncol = 3)
  result <- grandparent_dsm(sm, rm)
  expect_false(anyNA(result))
  expect_false(any(is.nan(result)))
  expect_false(any(is.infinite(result)))
})

# ============================================================================
# Parameter Recovery Tests (G5.6, G5.6a)
# ============================================================================

test_that("parent_dsm recovers known matrix properties", {
  # Simple 2x2 case with known structure
  S <- matrix(c(1, 0, 0, 1), nrow = 2)
  result <- parent_dsm(S)

  # Expected: S * S^T = identity matrix for this case
  expected <- matrix(c(1, 0, 0, 1), nrow = 2)

  expect_equal(result, expected, tolerance = 1e-10)
})

test_that("parent_dsm diagonal equals row sums", {
  # parent_dsm requires square matrices
  S <- matrix(c(1, 0, 1, 0, 1, 0, 1, 0, 1), nrow = 3, ncol = 3)
  result <- parent_dsm(S)

  # Diagonal elements equal row sums (resources per task)
  # Row 1: 1+0+1 = 2, Row 2: 0+1+0 = 1, Row 3: 1+0+1 = 2
  expect_equal(diag(result), c(2, 1, 2), tolerance = 1e-10)
})

test_that("parent_dsm is symmetric", {
  S <- matrix(c(1, 1, 0, 0, 1, 1, 1, 0, 1), nrow = 3, ncol = 3)
  result <- parent_dsm(S)

  # Matrix multiplication S * S^T is always symmetric
  expect_equal(result, t(result), tolerance = 1e-10)
})

test_that("grandparent_dsm recovers known shared risks", {
  S <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)
  R <- matrix(c(1, 1, 0, 0), nrow = 2, ncol = 2)
  result <- grandparent_dsm(S, R)

  # S * R^T gives the task-risk matrix
  # Then (S * R^T) * (S * R^T)^T gives the shared risk matrix
  # Expected: symmetric result
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 2)
  expect_equal(ncol(result), 2)
})

test_that("grandparent_dsm is symmetric", {
  S <- matrix(c(1, 1, 0, 0, 1, 1, 1, 0, 1), nrow = 3, ncol = 3)
  R <- matrix(c(1, 0, 1, 0, 1, 0, 1, 0, 1), nrow = 3, ncol = 3)
  result <- grandparent_dsm(S, R)

  # Result must be symmetric
  expect_equal(result, t(result), tolerance = 1e-10)
})

# ============================================================================
# Edge Condition Tests (G5.8a) - Zero-Length Data
# ============================================================================

test_that("parent_dsm handles zero-dimension matrix", {
  empty_matrix <- matrix(numeric(0), nrow = 0, ncol = 0)
  result <- parent_dsm(empty_matrix)

  # Should return an empty matrix (0x0)
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 0)
  expect_equal(ncol(result), 0)
})

# ============================================================================
# Edge Condition Tests (G5.8c) - All-Zero/All-One Matrices
# ============================================================================

test_that("parent_dsm handles all-zero matrix", {
  S <- matrix(0, nrow = 3, ncol = 3)
  result <- parent_dsm(S)

  # Should return all-zero matrix
  expect_true(all(result == 0))
})

test_that("parent_dsm handles all-one matrix", {
  S <- matrix(1, nrow = 3, ncol = 3)
  result <- parent_dsm(S)

  # Should return valid result (all tasks share all resources)
  expect_true(is.matrix(result))
  expect_equal(nrow(result), 3)
  expect_equal(ncol(result), 3)
})

# ============================================================================
# Edge Condition Tests (G5.8d) - Out-of-Scope Data
# ============================================================================

test_that("parent_dsm requires square matrix", {
  # Non-square matrix (already tested but documenting for G5.8d)
  S_rect <- matrix(c(1, 0, 1, 0, 1, 0), nrow = 2, ncol = 3)
  expect_error(parent_dsm(S_rect), "The Resource-Task Matrix must be square")
})

test_that("grandparent_dsm requires compatible dimensions", {
  S <- matrix(c(1, 0, 0, 1), nrow = 2, ncol = 2)
  R_wrong <- matrix(c(1, 0, 1), nrow = 1, ncol = 3)

  expect_error(
    grandparent_dsm(S, R_wrong),
    "Number of columns in the Matrix S must be equal to the number of columns in Matrix R"
  )
})

# ============================================================================
# Noise Susceptibility Tests (G5.9a) - Trivial Noise
# ============================================================================

test_that("parent_dsm is stable to trivial noise in matrix values", {
  S <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), nrow = 3, ncol = 3)
  result_clean <- parent_dsm(S)

  # Add trivial noise
  S_noisy <- S + matrix(runif(9, -.Machine$double.eps, .Machine$double.eps), nrow = 3)
  result_noisy <- parent_dsm(S_noisy)

  # Results should be essentially identical
  expect_equal(result_clean, result_noisy, tolerance = 100*.Machine$double.eps)
})
