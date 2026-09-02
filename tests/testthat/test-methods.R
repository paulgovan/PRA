#' @srrstats {G5.2a} *Method dispatch is verified for every exported S3 class.*
#' @srrstats {G5.8} *Degenerate inputs to plot methods are covered.*

# The JSS editor's review asked for print, summary and plot on every class the
# package returns. This file turns that requirement into a regression test.

pra_classes <- c("mcs", "smm", "dsm", "prob_net", "pra_sigmoidal_fit")

test_that("every PRA S3 class implements print, summary and plot (G5.2a)", {
  for (cls in pra_classes) {
    for (gen in c("print", "summary", "plot")) {
      expect_false(
        is.null(utils::getS3method(gen, cls, optional = TRUE)),
        info = paste0(gen, ".", cls, " is missing")
      )
    }
  }
})

test_that("print methods return their input invisibly (G5.3)", {
  task_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "uniform", min = 8, max = 12)
  )
  m <- mcs(500, task_dists)
  s <- smm(c(10, 15), c(4, 9))

  expect_output(expect_invisible(print(m)))
  expect_output(expect_invisible(print(s)))
  expect_output(expect_invisible(print(summary(m))))
  expect_output(expect_invisible(print(summary(s))))
})

test_that("summary methods return classed summary objects (G5.3)", {
  task_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "uniform", min = 8, max = 12)
  )
  expect_s3_class(summary(mcs(500, task_dists)), "summary.mcs")
  expect_s3_class(summary(smm(c(10, 15), c(4, 9))), "summary.smm")
})

test_that("summary.mcs reports the full percentile grid (G5.3)", {
  task_dists <- list(list(type = "normal", mean = 10, sd = 2))
  s <- summary(mcs(2000, task_dists))

  expect_equal(s$num_sims, 2000)
  expect_named(s$percentiles, c("5%", "10%", "25%", "50%", "75%", "90%", "95%"))
  # Percentiles are monotone and bracketed by the range.
  expect_false(is.unsorted(s$percentiles))
  expect_gte(s$percentiles[["5%"]], s$total_min)
  expect_lte(s$percentiles[["95%"]], s$total_max)
  expect_equal(s$cv, s$total_sd / s$total_mean)
})

test_that("summary.smm percentiles match the normal approximation (G5.3)", {
  result <- smm(c(10, 15, 20), c(4, 9, 16))
  s <- summary(result)

  expect_equal(s$total_variance, result$total_var)
  expect_equal(s$total_sd, result$total_std)
  expect_equal(
    unname(s$percentiles[["50%"]]), result$total_mean,
    tolerance = 1e-10
  )
  expect_equal(
    unname(s$percentiles[["95%"]]),
    stats::qnorm(0.95, result$total_mean, result$total_std),
    tolerance = 1e-10
  )
})

test_that("summary.dsm reports coupling structure (G5.3)", {
  S <- matrix(c(
    1, 1, 0,
    0, 1, 1
  ), nrow = 2, byrow = TRUE)
  colnames(S) <- c("Design", "Build", "Test")
  s <- summary(parent_dsm(S))

  expect_s3_class(s, "summary.dsm")
  expect_equal(s$type, "parent")
  expect_equal(s$n_tasks, 3)
  expect_named(s$degree, c("Design", "Build", "Test"))
  # Build shares a resource with each of the other two tasks.
  expect_equal(unname(s$degree[["Build"]]), 2)
  expect_equal(nrow(s$top_pairs), 2)

  out <- capture.output(print(s))
  expect_true(any(grepl("Tasks:", out)))
  expect_true(any(grepl("Coupling density", out)))
})

test_that("plot methods run and return their input invisibly (G5.8)", {
  withr::local_pdf(NULL)
  task_dists <- list(
    list(type = "normal", mean = 10, sd = 2),
    list(type = "uniform", min = 8, max = 12)
  )
  m <- mcs(500, task_dists)
  expect_no_error(plot(m))
  expect_invisible(plot(m))
  expect_no_error(plot(m, normal_fit = FALSE))

  expect_no_error(plot(smm(c(10, 15), c(4, 9))))

  S <- matrix(c(1, 1, 0, 0, 1, 1), nrow = 2, byrow = TRUE)
  expect_no_error(plot(parent_dsm(S)))
})

test_that("plot.smm messages when there is no variance to plot (G5.8)", {
  withr::local_pdf(NULL)
  expect_message(plot(smm(c(10, 15), c(0, 0))), "Nothing to plot")
})
