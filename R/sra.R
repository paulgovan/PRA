# Internal: Spearman rank correlation that returns NA, without a warning, when
# either input is constant.
safe_spearman <- function(a, b) {
  if (stats::sd(a) == 0 || stats::sd(b) == 0) return(NA_real_)
  stats::cor(a, b, method = "spearman")
}


# Internal: sample an iterations x activities duration matrix for a schedule,
# together with the per-iteration risk occurrences and risk costs.
sra_sample <- function(x, num_sims) {
  a <- x$activities
  n <- nrow(a)
  m <- num_sims
  D <- matrix(a$duration, m, n, byrow = TRUE)

  # Duration distributions, correlated through a Gaussian copula when a
  # correlation matrix is supplied (as in mcs()).
  nd <- length(x$dist_idx)
  if (nd > 0) {
    if (is.null(x$cor_mat)) {
      u <- matrix(stats::runif(m * nd), m, nd)
    } else {
      z <- matrix(stats::rnorm(m * nd), m, nd)
      u <- stats::pnorm(z %*% chol(x$cor_mat))
    }
    for (k in seq_len(nd)) {
      D[, x$dist_idx[k]] <- pra_qdist(x$duration_dists[[k]], u[, k])
    }
  }

  # Resource-driven durations from work, units and sampled productivity.
  nr <- nrow(x$resources)
  P <- matrix(1, m, nr)
  for (nm in names(x$productivity_dists)) {
    r <- match(nm, x$resources$id)
    P[, r] <- pra_qdist(x$productivity_dists[[nm]], stats::runif(m))
  }
  for (j in which(a$driver == "resource")) {
    d <- numeric(m)
    for (r in which(!is.na(x$work[j, ]))) {
      d <- pmax(d, x$work[j, r] / (x$units[j, r] * P[, r]))
    }
    D[, j] <- d
  }

  # Discrete risk events: one occurrence draw and one impact draw per risk per
  # iteration, applied to every activity the risk affects.
  K <- length(x$risks)
  occ <- matrix(FALSE, m, K)
  rcost <- matrix(0, m, K)
  for (k in seq_len(K)) {
    rk <- x$risks[[k]]
    occ[, k] <- stats::runif(m) < rk$prob
    if (!is.null(rk$impact)) {
      imp <- occ[, k] * pra_qdist(rk$impact, stats::runif(m))
      for (j in rk$act_idx) D[, j] <- D[, j] + imp
    }
    if (!is.null(rk$cost_impact)) {
      rcost[, k] <- occ[, k] * pra_qdist(rk$cost_impact, stats::runif(m))
    }
  }

  D[D < 0] <- 0
  list(D = D, occ = occ, rcost = rcost)
}


#' Schedule Risk Analysis.
#'
#' Monte Carlo schedule risk analysis of a resource-loaded project schedule.
#' Each iteration samples activity durations (from their distributions, or
#' from work and sampled resource productivity), samples which discrete risk
#' events occur and their impacts, and reschedules the network with the
#' critical path method (optionally resource-leveled; see [cpm()]). The
#' result describes the distribution of project finish and cost, how often
#' and how strongly each activity drives the finish, the impact of each risk,
#' and the uncertainty in the cost S-curve and resource usage over time.
#'
#' @details
#' **Activity measures.**
#' * *Criticality index*: the proportion of iterations in which the activity
#'   is critical (zero total float, or on the driving path when leveled).
#' * *Duration sensitivity*: Spearman rank correlation between the activity's
#'   sampled duration and the project finish.
#' * *Cruciality index*: criticality index times duration sensitivity
#'   (Williams, 1992), which ranks activities by how much they actually move
#'   the finish date.
#' * *Schedule sensitivity index (SSI)*: criticality index times the ratio of
#'   the activity's duration standard deviation to the project finish standard
#'   deviation (PMI, 2009).
#'
#' Measures based on duration spread are `NA` for activities whose duration
#' never varies.
#'
#' **Risk measures.** For each risk, the mean finish (and cost) in iterations
#' where it occurred minus the mean in iterations where it did not; `NA` when
#' the risk always or never occurred.
#'
#' **Merge bias.** Where paths converge, the finish is driven by the longest of
#' several uncertain paths, so the mean simulated finish usually exceeds the
#' deterministic finish even when every duration is symmetric. This is why a
#' network analysis differs from summing task durations with [mcs()].
#'
#' **Time-phasing.** Each activity's cost (resource cost, fixed cost and its
#' share of risk costs) is spread linearly over its scheduled dates. Resource
#' usage is the sum of assigned units over the activities running at each
#' time. Both are evaluated on `grid_n` points from zero to the latest
#' simulated finish and summarized by their mean and P10, P50 and P90.
#'
#' **Performance.** Without leveling, the critical path passes are vectorized
#' across iterations and are fast. Leveling schedules every iteration
#' separately with a serial schedule-generation scheme whose cost grows with
#' the square of the number of activities, so large leveled models may need
#' fewer iterations.
#'
#' The returned object carries `total_distribution`, so [contingency()]
#' applies directly to schedule contingency.
#'
#' @param x A `"pra_schedule"` object from [project_schedule()].
#' @param num_sims Number of Monte Carlo iterations. Default 10000.
#' @param level Logical. Resource-level each iteration. Default `FALSE`.
#' @param keep_samples Logical. Keep the per-iteration duration, start,
#'   finish, criticality and risk-occurrence matrices. Default `FALSE`.
#' @param grid_n Number of time points for the cost S-curve and resource
#'   profiles. Default 100.
#' @return An S3 object of class `"sra"`, a list with:
#' \describe{
#'   \item{total_distribution}{Simulated project finish, one per iteration.}
#'   \item{total_mean, total_sd}{Mean and standard deviation of the finish.}
#'   \item{percentiles}{P10, P50, P80 and P90 of the finish.}
#'   \item{cost_distribution}{Simulated project cost, one per iteration.}
#'   \item{cost_percentiles}{P10, P50, P80 and P90 of the cost.}
#'   \item{deterministic}{The [cpm()] result on baseline durations.}
#'   \item{prob_deterministic}{Probability of finishing no later than the
#'     deterministic finish.}
#'   \item{activity_stats}{Data frame of per-activity results: deterministic
#'     start and finish, mean and standard deviation of duration, mean and
#'     P10/P50/P90 start and finish, criticality index, duration sensitivity,
#'     cruciality and SSI.}
#'   \item{risk_stats}{Data frame of per-risk results: probability,
#'     simulated occurrence rate, finish impact, cost impact and rank by
#'     finish impact. Zero rows when there are no risks.}
#'   \item{time_grid}{Time points used for the curves below.}
#'   \item{cost_curve}{Data frame of cumulative cost over `time_grid`:
#'     `mean`, `p10`, `p50`, `p90`.}
#'   \item{resource_profile}{Named list, one data frame per resource, of
#'     usage over `time_grid` (`mean`, `p10`, `p50`, `p90`) with a `capacity`
#'     attribute.}
#'   \item{samples}{When `keep_samples = TRUE`, a list of iteration x activity
#'     matrices `duration`, `start`, `finish`, `critical`, and the iteration x
#'     risk matrix `risk_occurred`; otherwise `NULL`.}
#'   \item{leveled, num_sims, project}{Settings and the input schedule.}
#' }
#' Objects of this class have [print.sra()], [summary.sra()] and [plot.sra()]
#' methods.
#' @references
#' Williams, Terry M. Criticality in stochastic networks. Journal of the
#' Operational Research Society 43.4 (1992): 353-357.
#'
#' Project Management Institute. Practice Standard for Project Risk
#' Management. Newtown Square, PA: PMI, 2009.
#'
#' Vanhoucke, Mario. Measuring time: Improving project performance using
#' earned value management. Springer, 2009.
#' @srrstats {G1.0} *Software lists primary references from published academic literature.*
#' @srrstats {G1.4} *Software uses roxygen2 to document all functions.*
#' @srrstats {G2.0} *Asserts that num_sims, level, keep_samples and grid_n are single values.*
#' @srrstats {G2.1} *Asserts the types of all inputs.*
#' @srrstats {G2.2} *Prohibits multivariate input to univariate parameters.*
#' @srrstats {G2.4a} *Uses as.integer() for integer comparison of num_sims and grid_n.*
#' @srrstats {G2.13} *Implements checks for NA values in num_sims.*
#' @srrstats {G2.15} *Implements checks for NaN values in num_sims.*
#' @srrstats {G2.16} *Implements checks for Inf values in num_sims.*
#' @srrstats {G3.1} *Correlation among durations is user-controlled via the schedule's cor_mat.*
#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*
#' @examples
#' activities <- data.frame(id = c("A", "B", "C", "D"), duration = c(3, 5, 4, 2))
#' links <- data.frame(
#'   source = c("A", "A", "B", "C"),
#'   target = c("B", "C", "D", "D")
#' )
#' duration_dists <- list(
#'   B = list(type = "triangular", a = 4, b = 5, c = 9),
#'   C = list(type = "triangular", a = 3, b = 4, c = 8)
#' )
#' risks <- list(list(
#'   id = "Rework", prob = 0.2, activities = "D",
#'   impact = list(type = "uniform", min = 1, max = 2)
#' ))
#' proj <- project_schedule(activities, links,
#'   duration_dists = duration_dists, risks = risks
#' )
#' set.seed(42)
#' res <- sra(proj, num_sims = 2000)
#' res
#' res$activity_stats[, c("id", "criticality", "cruciality")]
#' contingency(res, phigh = 0.8, pbase = 0.5)
#' @export
sra <- function(x, num_sims = 10000, level = FALSE, keep_samples = FALSE,
                grid_n = 100) {
  check_schedule(x)
  if (!is.numeric(num_sims) || length(num_sims) != 1) {
    stop("num_sims must be a single positive integer")
  }
  if (is.nan(num_sims)) stop("num_sims must not be NaN")
  if (is.na(num_sims)) stop("num_sims must not be NA")
  if (is.infinite(num_sims)) stop("num_sims must not be infinite")
  if (num_sims < 2 || num_sims != as.integer(num_sims)) {
    stop("num_sims must be an integer of at least 2")
  }
  check_flag(level, "level")
  check_flag(keep_samples, "keep_samples")
  if (!is.numeric(grid_n) || length(grid_n) != 1 || is.na(grid_n) ||
      is.infinite(grid_n) || grid_n < 2 || grid_n != as.integer(grid_n)) {
    stop("grid_n must be a single integer of at least 2")
  }
  num_sims <- as.integer(num_sims)

  a <- x$activities
  n <- nrow(a)
  if (level && n * num_sims > 2e6) {
    message(
      "Resource leveling schedules each of the ", num_sims, " iterations ",
      "separately; consider fewer iterations if this is slow."
    )
  }

  smp <- sra_sample(x, num_sims)
  D <- smp$D
  run <- sched_run(D, x, level = level)
  finish <- run$finish
  crit <- run$critical

  # ---- Cost ----
  A <- D * matrix(sched_cost_rate(x), num_sims, n, byrow = TRUE) +
    matrix(a$fixed_cost, num_sims, n, byrow = TRUE)
  for (k in seq_along(x$risks)) {
    idx <- x$risks[[k]]$act_idx
    share <- smp$rcost[, k] / length(idx)
    for (j in idx) A[, j] <- A[, j] + share
  }
  cost <- rowSums(A)

  # ---- Activity measures ----
  sd_T <- stats::sd(finish)
  ci <- colMeans(crit)
  sens <- vapply(seq_len(n), function(j) safe_spearman(D[, j], finish), numeric(1))
  sd_d <- apply(D, 2, stats::sd)
  q3 <- function(M, p) apply(M, 2, stats::quantile, probs = p, names = FALSE)
  det <- cpm(x, level = level)
  activity_stats <- data.frame(
    id = a$id, name = a$name,
    det_start = det$activities$ES, det_finish = det$activities$EF,
    mean_duration = colMeans(D), sd_duration = sd_d,
    mean_start = colMeans(run$ES),
    start_p10 = q3(run$ES, 0.10), start_p50 = q3(run$ES, 0.50),
    start_p90 = q3(run$ES, 0.90),
    mean_finish = colMeans(run$EF),
    finish_p10 = q3(run$EF, 0.10), finish_p50 = q3(run$EF, 0.50),
    finish_p90 = q3(run$EF, 0.90),
    criticality = ci,
    sensitivity = sens,
    cruciality = ci * sens,
    ssi = if (sd_T > 0) ci * sd_d / sd_T else rep(NA_real_, n),
    stringsAsFactors = FALSE
  )
  activity_stats$ssi[sd_d == 0] <- NA_real_

  # ---- Risk measures ----
  K <- length(x$risks)
  risk_stats <- data.frame(
    id = character(0), prob = numeric(0), occurrence = numeric(0),
    finish_impact = numeric(0), cost_impact = numeric(0), rank = integer(0),
    stringsAsFactors = FALSE
  )
  if (K > 0) {
    diff_mean <- function(v, o) {
      if (all(o) || !any(o)) return(NA_real_)
      mean(v[o]) - mean(v[!o])
    }
    fi <- vapply(seq_len(K), function(k) diff_mean(finish, smp$occ[, k]), numeric(1))
    risk_stats <- data.frame(
      id = vapply(x$risks, `[[`, character(1), "id"),
      prob = vapply(x$risks, `[[`, numeric(1), "prob"),
      occurrence = colMeans(smp$occ),
      finish_impact = fi,
      cost_impact = vapply(seq_len(K), function(k) diff_mean(cost, smp$occ[, k]), numeric(1)),
      rank = rank(-ifelse(is.na(fi), -Inf, fi), ties.method = "first"),
      stringsAsFactors = FALSE
    )
  }

  # ---- Time-phased curves ----
  grid <- seq(0, max(finish, sched_tol(0)), length.out = grid_n)
  cost_curve <- sched_band(sched_cumulative(A, run$ES, run$EF, grid), grid)
  resource_profile <- list()
  for (r in seq_len(nrow(x$resources))) {
    band <- sched_band(sched_usage(x$units[, r], run$ES, run$EF, grid), grid)
    attr(band, "capacity") <- x$resources$capacity[r]
    resource_profile[[x$resources$id[r]]] <- band
  }

  probs <- c(0.10, 0.50, 0.80, 0.90)
  result <- list(
    total_distribution = finish,
    total_mean = mean(finish),
    total_sd = sd_T,
    percentiles = stats::quantile(finish, probs = probs),
    cost_distribution = cost,
    cost_percentiles = stats::quantile(cost, probs = probs),
    deterministic = det,
    prob_deterministic = mean(finish <= det$finish + sched_tol(det$finish)),
    activity_stats = activity_stats,
    risk_stats = risk_stats,
    time_grid = grid,
    cost_curve = cost_curve,
    resource_profile = resource_profile,
    samples = if (keep_samples) {
      list(
        duration = D, start = run$ES, finish = run$EF, critical = crit,
        risk_occurred = smp$occ
      )
    },
    leveled = level,
    num_sims = num_sims,
    project = x
  )
  class(result) <- "sra"
  result
}


#' Print schedule risk analysis results.
#'
#' @param x An object of class `"sra"`.
#' @param ... Additional arguments (not used).
#' @return Invisibly returns `x`.
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B"), duration = c(2, 3)),
#'   data.frame(source = "A", target = "B"),
#'   duration_dists = list(B = list(type = "triangular", a = 2, b = 3, c = 6))
#' )
#' print(sra(proj, num_sims = 500))
#' @export
#' @method print sra
print.sra <- function(x, ...) {
  tu <- x$project$time_unit
  cat("Schedule Risk Analysis", if (x$leveled) "(resource-leveled)", "\n")
  cat("Iterations:", format(x$num_sims, big.mark = ",", scientific = FALSE), "\n")
  cat("Deterministic finish:", format(signif(x$deterministic$finish, 4)), tu,
      sprintf("(P%.0f)", 100 * x$prob_deterministic), "\n")
  cat("Mean finish:", format(signif(x$total_mean, 4)), tu,
      "  SD:", format(signif(x$total_sd, 4)), "\n")
  cat("Finish percentiles:\n")
  print(signif(x$percentiles, 4))
  if (any(x$cost_distribution != 0)) {
    cat("Cost percentiles:\n")
    print(signif(x$cost_percentiles, 4))
  }
  top <- x$activity_stats[order(-x$activity_stats$criticality), ]
  top <- top[top$criticality > 0, c("id", "criticality", "cruciality")]
  top <- top[seq_len(min(5, nrow(top))), , drop = FALSE]
  if (nrow(top) > 0) {
    cat("Most critical activities:\n")
    top[-1] <- lapply(top[-1], round, 3)
    print(top, row.names = FALSE)
  }
  invisible(x)
}


#' Summarize schedule risk analysis results.
#'
#' @param object An object of class `"sra"`.
#' @param ... Additional arguments (not used).
#' @return An object of class `"summary.sra"`, a list with the finish and cost
#'   distribution summaries (mean, standard deviation, coefficient of
#'   variation and P5-P95 percentiles), the deterministic finish and cost and
#'   the probability of meeting them, the activity table ordered by
#'   cruciality, and the risk table ordered by rank.
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B"), duration = c(2, 3)),
#'   data.frame(source = "A", target = "B"),
#'   duration_dists = list(B = list(type = "triangular", a = 2, b = 3, c = 6))
#' )
#' summary(sra(proj, num_sims = 500))
#' @export
#' @method summary sra
summary.sra <- function(object, ...) {
  probs <- c(0.05, 0.10, 0.25, 0.50, 0.75, 0.80, 0.90, 0.95)
  dsum <- function(v) {
    m <- mean(v)
    list(
      mean = m, sd = stats::sd(v),
      cv = if (m != 0) stats::sd(v) / m else NA_real_,
      percentiles = stats::quantile(v, probs = probs)
    )
  }
  act <- object$activity_stats
  ord <- order(-ifelse(is.na(act$cruciality), -Inf, act$cruciality), -act$criticality)
  result <- list(
    num_sims = object$num_sims,
    leveled = object$leveled,
    finish = dsum(object$total_distribution),
    cost = dsum(object$cost_distribution),
    deterministic_finish = object$deterministic$finish,
    deterministic_cost = object$deterministic$cost,
    prob_deterministic = object$prob_deterministic,
    prob_deterministic_cost = mean(object$cost_distribution <=
      object$deterministic$cost + sched_tol(object$deterministic$cost)),
    activities = act[ord, c("id", "mean_duration", "mean_finish", "finish_p90",
                            "criticality", "sensitivity", "cruciality", "ssi")],
    risks = object$risk_stats[order(object$risk_stats$rank), ],
    time_unit = object$project$time_unit
  )
  class(result) <- "summary.sra"
  result
}


#' Print a schedule risk analysis summary.
#'
#' @param x An object of class `"summary.sra"`.
#' @param ... Additional arguments (not used).
#' @return Invisibly returns `x`.
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B"), duration = c(2, 3)),
#'   data.frame(source = "A", target = "B"),
#'   duration_dists = list(B = list(type = "triangular", a = 2, b = 3, c = 6))
#' )
#' print(summary(sra(proj, num_sims = 500)))
#' @export
#' @method print summary.sra
print.summary.sra <- function(x, ...) {
  tu <- x$time_unit
  cat("Schedule Risk Analysis Summary", if (x$leveled) "(resource-leveled)", "\n")
  cat("------------------------------\n")
  cat("Iterations:", format(x$num_sims, big.mark = ",", scientific = FALSE), "\n\n")
  cat("Finish (", tu, ")\n", sep = "")
  cat("  Deterministic:", format(signif(x$deterministic_finish, 4)),
      sprintf(" (probability of meeting it: %.1f%%)", 100 * x$prob_deterministic), "\n")
  cat("  Mean:", format(signif(x$finish$mean, 4)), "  SD:", format(signif(x$finish$sd, 4)),
      "  CV:", format(round(x$finish$cv, 4)), "\n")
  print(signif(x$finish$percentiles, 4))
  if (x$cost$mean != 0 || x$deterministic_cost != 0) {
    cat("\nCost\n")
    cat("  Deterministic:", format(signif(x$deterministic_cost, 6), big.mark = ","),
        sprintf(" (probability of meeting it: %.1f%%)", 100 * x$prob_deterministic_cost), "\n")
    cat("  Mean:", format(signif(x$cost$mean, 6), big.mark = ","),
        "  SD:", format(signif(x$cost$sd, 6), big.mark = ","), "\n")
    print(signif(x$cost$percentiles, 6))
  }
  cat("\nActivities (by cruciality)\n")
  act <- x$activities
  num <- vapply(act, is.numeric, logical(1))
  act[num] <- lapply(act[num], round, 3)
  print(act, row.names = FALSE)
  if (nrow(x$risks) > 0) {
    cat("\nRisk events (by finish impact)\n")
    rk <- x$risks
    num <- vapply(rk, is.numeric, logical(1))
    rk[num] <- lapply(rk[num], signif, 4)
    print(rk, row.names = FALSE)
  }
  invisible(x)
}
