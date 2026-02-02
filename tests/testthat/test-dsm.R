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
