test_that("second moment analysis works without correlation matrix", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)
  results <- smm(mean, var)

  expect_equal(results$total_mean, 10 + 15 + 20)
  expect_equal(results$total_std, sqrt(4 + 9 + 16))
})

test_that("second moment analysis works with correlation matrix", {
  mean <- c(10, 15, 20)
  var <- c(4, 9, 16)

  cor_mat <- matrix(c(
    1, 0.5, 0.3,
    0.5, 1, 0.4,
    0.3, 0.4, 1
    ), nrow = 3, byrow = TRUE)

  results <- smm(mean, var, cor_mat)

  task_variances <- c(4,  9, 16)

  cov_matrix <- matrix(0, nrow = 3, ncol = 3)
  for (i in 1:3) {
    for (j in 1:3) {
      cov_matrix[i, j] <- cor_mat[i, j] * sqrt(task_variances[i] * task_variances[j])
    }
  }

  total_variance <- sum(task_variances) + sum(cov_matrix[upper.tri(cov_matrix)] * 2)

  expect_equal(results$total_mean, 10 + 15 + 20)
  expect_equal(results$total_std, sqrt(total_variance))
})

