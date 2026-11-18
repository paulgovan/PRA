#' @srrstats {G5.2} *Error behaviour is explicitly demonstrated through tests.*
#' @srrstats {G5.2b} *Tests trigger every error message and compare with expected values.*
#' @srrstats {G5.3} *Return objects tested for absence of NA, NaN, Inf.*
#' @srrstats {G5.5} *Stochastic tests use fixed seeds.*
#' @srrstats {G5.6} *Parameter recovery: degenerate distributions reproduce the deterministic CPM schedule; a series network reproduces mcs().*
#' @srrstats {G5.6a} *Stochastic recovery succeeds within stated tolerances.*
#' @srrstats {G5.6b} *Recovery is checked across several seeds.*
#' @srrstats {G5.7} *Correlation and leveling change results in the expected direction.*
#' @srrstats {G5.8} *Edge conditions: certain and impossible risks, constant durations.*
#' @srrstats {G5.9b} *Results are reproducible for a fixed seed and stable across seeds.*

series_project <- function(cor_mat = NULL) {
  project_schedule(
    data.frame(id = c("A", "B", "C")),
    data.frame(source = c("A", "B"), target = c("B", "C")),
    duration_dists = list(
      A = list(type = "normal", mean = 10, sd = 2),
      B = list(type = "triangular", a = 5, b = 10, c = 15),
      C = list(type = "uniform", min = 8, max = 12)
    ),
    cor_mat = cor_mat
  )
}

parallel_project <- function() {
  project_schedule(
    data.frame(id = c("S", "X", "Y", "F"), duration = c(0, 10, 10, 0)),
    data.frame(source = c("S", "S", "X", "Y"), target = c("X", "Y", "F", "F")),
    duration_dists = list(
      X = list(type = "triangular", a = 8, b = 10, c = 12),
      Y = list(type = "triangular", a = 8, b = 10, c = 12)
    )
  )
}

test_that("sra validates its arguments (G5.2b)", {
  p <- series_project()
  expect_error(sra(list()), "x must be a pra_schedule object created by project_schedule()", fixed = TRUE)
  expect_error(sra(p, num_sims = "a"), "num_sims must be a single positive integer")
  expect_error(sra(p, num_sims = c(10, 20)), "num_sims must be a single positive integer")
  expect_error(sra(p, num_sims = NaN), "num_sims must not be NaN")
  expect_error(sra(p, num_sims = NA_real_), "num_sims must not be NA")
  expect_error(sra(p, num_sims = Inf), "num_sims must not be infinite")
  expect_error(sra(p, num_sims = 1), "num_sims must be an integer of at least 2")
  expect_error(sra(p, num_sims = 10.5), "num_sims must be an integer of at least 2")
  expect_error(sra(p, 10, level = NA), "level must be a single TRUE or FALSE")
  expect_error(sra(p, 10, keep_samples = "yes"), "keep_samples must be a single TRUE or FALSE")
  expect_error(sra(p, 10, grid_n = 1), "grid_n must be a single integer of at least 2")
  expect_error(sra(p, 10, grid_n = NA), "grid_n must be a single integer of at least 2")
})

test_that("degenerate distributions reproduce the deterministic schedule (G5.6)", {
  p <- project_schedule(
    data.frame(id = LETTERS[1:4], duration = c(2, 4, 3, 1)),
    data.frame(source = c("A", "A", "B", "C"), target = c("B", "C", "D", "D"),
               type = c("FS", "SS", "FS", "FF"), lag = c(0, 1, 0, 2)),
    duration_dists = list(
      B = list(type = "normal", mean = 4, sd = 0),
      C = list(type = "triangular", a = 3, b = 3, c = 3)
    )
  )
  set.seed(1)
  res <- sra(p, 200)
  det <- cpm(p)
  expect_true(all(res$total_distribution == det$finish))
  expect_equal(res$activity_stats$criticality, as.numeric(det$activities$critical))
  expect_equal(res$activity_stats$finish_p50, det$activities$EF)
  expect_equal(res$prob_deterministic, 1)
  expect_true(all(is.na(res$activity_stats$sensitivity)))
  expect_true(all(is.na(res$activity_stats$ssi)))
})

test_that("a series network matches mcs() on the same distributions (G5.6a, G5.6b)", {
  for (seed in c(1, 42, 2024)) {
    set.seed(seed)
    res <- sra(series_project(), 20000)
    set.seed(seed + 1)
    ref <- mcs(20000, series_project()$duration_dists)
    expect_equal(res$total_mean, ref$total_mean, tolerance = 0.01)
    expect_equal(res$total_sd, ref$total_sd, tolerance = 0.03)
    # Every activity in a single chain is always critical.
    expect_equal(res$activity_stats$criticality, c(1, 1, 1))
  }
})

test_that("correlation widens the finish distribution (G5.7)", {
  cm <- matrix(0.8, 3, 3)
  diag(cm) <- 1
  set.seed(7)
  indep <- sra(series_project(), 20000)
  set.seed(7)
  corr <- sra(series_project(cm), 20000)
  expect_gt(corr$total_sd, indep$total_sd * 1.3)
  expect_equal(corr$total_mean, indep$total_mean, tolerance = 0.01)
})

test_that("parallel paths split criticality and show merge bias", {
  set.seed(3)
  res <- sra(parallel_project(), 20000)
  ci <- stats::setNames(res$activity_stats$criticality, res$activity_stats$id)
  expect_equal(unname(ci[c("X", "Y")]), c(0.5, 0.5), tolerance = 0.05)
  expect_equal(unname(ci[c("S", "F")]), c(1, 1))
  # Symmetric durations, yet the mean finish exceeds the deterministic 10.
  expect_gt(res$total_mean, 10.3)
  expect_lt(res$prob_deterministic, 0.35)
})

test_that("certain and impossible risks behave exactly (G5.8)", {
  fixed <- data.frame(id = c("A", "B"), duration = c(3, 4))
  lk <- data.frame(source = "A", target = "B")
  certain <- list(list(id = "always", prob = 1, activities = "A",
                       impact = list(type = "uniform", min = 2, max = 2),
                       cost_impact = list(type = "uniform", min = 500, max = 500)))
  never <- list(list(id = "never", prob = 0, activities = "A",
                     impact = list(type = "uniform", min = 2, max = 2)))
  res1 <- sra(project_schedule(fixed, lk, risks = certain), 50)
  expect_true(all(res1$total_distribution == 9))
  expect_true(all(res1$cost_distribution == 500))
  expect_equal(res1$risk_stats$occurrence, 1)
  expect_true(is.na(res1$risk_stats$finish_impact))
  res0 <- sra(project_schedule(fixed, lk, risks = never), 50)
  expect_true(all(res0$total_distribution == 7))
  expect_equal(res0$risk_stats$occurrence, 0)
})

test_that("risk impacts are measured and ranked", {
  p <- project_schedule(
    data.frame(id = c("A", "B"), duration = c(5, 5)),
    data.frame(source = "A", target = "B"),
    risks = list(
      list(id = "small", prob = 0.5, activities = "A",
           impact = list(type = "uniform", min = 1, max = 1)),
      list(id = "big", prob = 0.3, activities = "B",
           impact = list(type = "uniform", min = 4, max = 4))
    )
  )
  set.seed(11)
  res <- sra(p, 5000)
  rs <- res$risk_stats
  expect_equal(rs$finish_impact, c(1, 4), tolerance = 0.1)
  expect_equal(rs$rank, c(2L, 1L))
  expect_equal(rs$occurrence, c(0.5, 0.3), tolerance = 0.03)
})

test_that("results are reproducible for a fixed seed (G5.9b)", {
  set.seed(99)
  a <- sra(parallel_project(), 500)
  set.seed(99)
  b <- sra(parallel_project(), 500)
  expect_identical(a$total_distribution, b$total_distribution)
  expect_identical(a$activity_stats, b$activity_stats)
})

test_that("productivity drives resource-driven durations and cost", {
  p <- project_schedule(
    data.frame(id = c("A", "B"), duration = c(2, NA), fixed_cost = c(0, 100)),
    data.frame(source = "A", target = "B"),
    resources = data.frame(id = "crew", rate = 10),
    productivity_dists = list(crew = list(type = "uniform", min = 0.5, max = 0.5)),
    assignments = data.frame(activity = "B", resource = "crew", units = 2, work = 8)
  )
  # Baseline 8 / 2 = 4 at productivity 1; halved productivity doubles it.
  expect_equal(cpm(p)$finish, 6)
  res <- sra(p, 20)
  expect_true(all(res$total_distribution == 10))
  # Cost: 2 units * 10 per unit-period * 8 periods + 100 fixed.
  expect_true(all(res$cost_distribution == 260))
  expect_equal(cpm(p)$cost, 180)
})

test_that("cost and the cost curve add up (G5.3)", {
  p <- project_schedule(
    data.frame(id = c("A", "B"), fixed_cost = c(50, 0)),
    data.frame(source = "A", target = "B"),
    duration_dists = list(
      A = list(type = "triangular", a = 1, b = 2, c = 4),
      B = list(type = "pert", a = 2, b = 3, c = 6)
    ),
    resources = data.frame(id = "crew", rate = 100),
    assignments = data.frame(activity = c("A", "B"), resource = "crew", units = c(1, 2)),
    risks = list(list(id = "claim", prob = 0.4, activities = c("A", "B"),
                      cost_impact = list(type = "uniform", min = 10, max = 30)))
  )
  set.seed(5)
  res <- sra(p, 2000, keep_samples = TRUE)
  d <- res$samples$duration
  base <- 50 + 100 * d[, 1] + 200 * d[, 2]
  extra <- res$cost_distribution - base
  occ <- res$samples$risk_occurred[, 1]
  expect_true(all(abs(extra[!occ]) < 1e-8))
  expect_true(all(extra[occ] >= 10 - 1e-8 & extra[occ] <= 30 + 1e-8))
  # The cumulative cost curve is non-decreasing and ends at total cost.
  cc <- res$cost_curve
  expect_true(all(diff(cc$p50) >= -1e-8))
  expect_equal(utils::tail(cc$p50, 1), unname(stats::quantile(res$cost_distribution, 0.5)),
               tolerance = 1e-6)
  for (nm in c("total_distribution", "cost_distribution")) {
    expect_false(any(!is.finite(res[[nm]])))
  }
  expect_equal(dim(res$samples$start), c(2000, 2))
  expect_null(sra(p, 10)$samples)
})

test_that("leveling respects capacity in every iteration (G5.7)", {
  p <- project_schedule(
    data.frame(id = c("X", "Y")),
    duration_dists = list(
      X = list(type = "uniform", min = 2, max = 4),
      Y = list(type = "uniform", min = 2, max = 4)
    ),
    resources = data.frame(id = "crew", capacity = 1),
    assignments = data.frame(activity = c("X", "Y"), resource = "crew", units = 1)
  )
  set.seed(8)
  free <- sra(p, 300, keep_samples = TRUE)
  set.seed(8)
  lev <- sra(p, 300, level = TRUE, keep_samples = TRUE)
  d <- lev$samples$duration
  expect_equal(free$total_distribution, pmax(d[, 1], d[, 2]))
  expect_equal(lev$total_distribution, d[, 1] + d[, 2])
  # Both activities are on the driving path once serialized.
  expect_equal(lev$activity_stats$criticality, c(1, 1))
  expect_lte(max(lev$resource_profile$crew$p90), 1)
  expect_gt(max(free$resource_profile$crew$p90), 1)
  expect_equal(attr(lev$resource_profile$crew, "capacity"), 1)
  expect_true(lev$leveled)
})

test_that("leveled criticality excludes activities off the driving path", {
  p <- project_schedule(
    data.frame(id = c("A", "B", "side"), duration = c(3, 3, 1)),
    resources = data.frame(id = "crew", capacity = 1),
    assignments = data.frame(activity = c("A", "B"), resource = "crew", units = 1)
  )
  res <- sra(p, 20, level = TRUE)
  expect_equal(res$activity_stats$criticality, c(1, 1, 0))
})

test_that("sra results work with contingency()", {
  set.seed(2)
  res <- sra(parallel_project(), 2000)
  cont <- contingency(res, phigh = 0.9, pbase = 0.5)
  expect_equal(unname(cont),
               unname(diff(stats::quantile(res$total_distribution, c(0.5, 0.9)))))
})

test_that("print and summary report results (G5.3)", {
  set.seed(4)
  p <- project_schedule(
    data.frame(id = c("A", "B")),
    data.frame(source = "A", target = "B"),
    duration_dists = list(
      A = list(type = "triangular", a = 1, b = 2, c = 4),
      B = list(type = "triangular", a = 1, b = 2, c = 4)
    ),
    resources = data.frame(id = "crew", rate = 10),
    assignments = data.frame(activity = "A", resource = "crew", units = 1),
    risks = list(list(id = "R", prob = 0.5, activities = "B",
                      impact = list(type = "uniform", min = 1, max = 2)))
  )
  res <- sra(p, 500)
  expect_output(expect_invisible(print(res)), "Schedule Risk Analysis")
  expect_output(print(res), "Cost percentiles")
  s <- summary(res)
  expect_s3_class(s, "summary.sra")
  expect_equal(nrow(s$activities), 2)
  expect_equal(s$risks$id, "R")
  expect_named(s$finish$percentiles,
               c("5%", "10%", "25%", "50%", "75%", "80%", "90%", "95%"))
  expect_output(expect_invisible(print(s)), "Risk events")
  expect_output(print(summary(sra(p, 50, level = TRUE))), "resource-leveled")
})

# ---- Risk networks: productivity and rate effects through resources ----

# Two independent 1/0 events with fixed probabilities, plus a constant
# severity node used for "node" magnitudes.
event_net <- function(p1 = 1, p2 = 1, severity = 0.5) {
  prob_net(
    data.frame(id = c("E1", "E2", "Sev")),
    data.frame(source = character(0), target = character(0)),
    list(
      E1 = list(type = "discrete", values = c(1, 0), probs = c(p1, 1 - p1)),
      E2 = list(type = "discrete", values = c(1, 0), probs = c(p2, 1 - p2)),
      Sev = list(type = "normal", mean = severity, sd = 0)
    )
  )
}

fixed_mult <- function(v) list(type = "uniform", min = v, max = v)

# Four parallel activities: A uses crew (duration-driven), B is work-driven on
# crew, C uses crew and crane, D uses nothing.
crew_project <- function(effects, net = event_net()) {
  project_schedule(
    data.frame(id = c("A", "B", "C", "D"), duration = c(4, NA, 6, 5)),
    resources = data.frame(id = c("crew", "crane"), rate = c(10, 100)),
    assignments = data.frame(
      activity = c("A", "B", "C", "C"), resource = c("crew", "crew", "crew", "crane"),
      units = c(1, 2, 1, 1), work = c(NA, 8, NA, NA)
    ),
    risk_net = net, risk_effects = effects
  )
}

test_that("a productivity effect slows every activity using the resource", {
  p <- crew_project(list(
    list(node = "E1", resources = "crew", effect = "productivity", magnitude = fixed_mult(0.5))
  ))
  res <- sra(p, 20, keep_samples = TRUE)
  d <- res$samples$duration
  expect_true(all(d[, 1] == 8))                       # 4 / 0.5
  expect_true(all(d[, 2] == 8))                       # work 8 / (2 * 0.5)
  expect_true(all(d[, 3] == 12))                      # 6 / 0.5, crew governs
  expect_true(all(d[, 4] == 5))                       # unassigned
  expect_true(all(res$samples$productivity_multiplier[, 1] == 0.5))
  expect_true(all(res$samples$productivity_multiplier[, 2] == 1))
  # The deterministic baseline is unaffected.
  expect_equal(cpm(p)$finish, 6)
})

test_that("the most affected resource governs and multipliers compound", {
  p <- crew_project(list(
    list(node = "E1", resources = "crane", effect = "productivity", magnitude = fixed_mult(0.5)),
    list(node = "E1", resources = "crew", effect = "productivity", magnitude = fixed_mult(0.8)),
    list(node = "E2", resources = "crew", effect = "productivity", magnitude = fixed_mult(0.5))
  ))
  d <- sra(p, 10, keep_samples = TRUE)$samples$duration
  expect_equal(unique(d[, 1]), 4 / 0.4)              # crew: 0.8 * 0.5
  expect_equal(unique(d[, 3]), 6 / 0.4)              # min(crew 0.4, crane 0.5)
})

test_that("a rate effect scales the cost of the resource's assignments", {
  base <- sra(crew_project(NULL), 10)
  p <- crew_project(list(
    list(node = "E1", resources = "crane", effect = "rate", magnitude = fixed_mult(2))
  ))
  res <- sra(p, 10, keep_samples = TRUE)
  # Crane cost on C: 1 unit * 100 * 6 periods, doubled.
  expect_equal(unique(res$cost_distribution - base$cost_distribution), 600)
  expect_equal(unique(res$total_distribution), 6)
  expect_true(all(res$samples$rate_multiplier[, 2] == 2))
})

test_that("effects apply only when the node is non-zero", {
  p <- crew_project(list(
    list(node = "E1", resources = "crew", effect = "productivity", magnitude = fixed_mult(0.5))
  ), net = event_net(p1 = 0.5))
  set.seed(21)
  res <- sra(p, 4000, keep_samples = TRUE)
  on <- res$samples$risk_net$E1 == 1
  expect_true(all(res$samples$duration[on, 1] == 8))
  expect_true(all(res$samples$duration[!on, 1] == 4))
  st <- res$risk_net_stats
  expect_equal(st$kind, c("event", "event", "continuous"))
  expect_equal(st$occurrence[1], 0.5, tolerance = 0.05)
  # When E1 occurs, C (6 -> 12) sets the finish; otherwise C's 6 does.
  expect_equal(st$finish_impact[1], 6, tolerance = 1e-8)
  expect_true(is.na(st$finish_impact[2]))            # E2 always occurs
  expect_equal(st$rank[1], 1L)
})

test_that("'node' magnitudes use the node's value in every iteration", {
  p <- crew_project(list(
    list(node = "Sev", resources = "crew", effect = "productivity", magnitude = "node"),
    list(node = "Sev", resources = "crane", effect = "rate", magnitude = "node")
  ), net = event_net(p1 = 0, p2 = 0, severity = 0.25))
  res <- sra(p, 10, keep_samples = TRUE)
  expect_equal(unique(res$samples$duration[, 1]), 16)
  expect_true(all(res$samples$rate_multiplier[, 2] == 0.25))
  expect_true(is.na(res$risk_net_stats$occurrence[3]))
})

test_that("invalid node values are caught at simulation time (G5.2b)", {
  neg <- crew_project(list(
    list(node = "Sev", resources = "crew", effect = "productivity", magnitude = "node")
  ), net = event_net(severity = 0))
  expect_error(sra(neg, 10), "risk_effects[[1]] uses node 'Sev' as a productivity multiplier, but it produced non-positive values", fixed = TRUE)
  neg_rate <- crew_project(list(
    list(node = "Sev", resources = "crew", effect = "rate", magnitude = "node")
  ), net = event_net(severity = -1))
  expect_error(sra(neg_rate, 10), "risk_effects[[1]] uses node 'Sev' as a rate multiplier, but it produced negative values", fixed = TRUE)
  na_net <- prob_net(
    data.frame(id = "N"), data.frame(source = character(0), target = character(0)),
    list(N = list(type = "discrete", values = c(NA, 1), probs = c(0.5, 0.5)))
  )
  na_proj <- crew_project(list(
    list(node = "N", resources = "crew", effect = "rate", magnitude = "node")
  ), net = na_net)
  expect_error(sra(na_proj, 50), "risk_effects[[1]] node 'N' produced NA values", fixed = TRUE)
})

test_that("a shared root cause makes resource effects occur together", {
  net <- prob_net(
    data.frame(id = c("Root", "R1", "R2")),
    data.frame(source = c("Root", "Root"), target = c("R1", "R2")),
    list(
      Root = list(type = "discrete", values = c(1, 0), probs = c(0.5, 0.5)),
      R1 = list(type = "conditional", condition = "Root",
                true_dist = list(type = "discrete", values = 1, probs = 1),
                false_dist = list(type = "discrete", values = 0, probs = 1)),
      R2 = list(type = "conditional", condition = "Root",
                true_dist = list(type = "discrete", values = 1, probs = 1),
                false_dist = list(type = "discrete", values = 0, probs = 1))
    )
  )
  p <- project_schedule(
    data.frame(id = c("X", "Y"), duration = c(10, 10)),
    resources = data.frame(id = c("crew1", "crew2")),
    assignments = data.frame(activity = c("X", "Y"), resource = c("crew1", "crew2"), units = 1),
    risk_net = net,
    risk_effects = list(
      list(node = "R1", resources = "crew1", effect = "productivity", magnitude = fixed_mult(0.5)),
      list(node = "R2", resources = "crew2", effect = "productivity", magnitude = fixed_mult(0.5))
    )
  )
  set.seed(9)
  res <- sra(p, 2000, keep_samples = TRUE)
  expect_setequal(unique(res$total_distribution), c(10, 20))
  expect_equal(res$samples$risk_net$R1, res$samples$risk_net$R2)
  st <- res$risk_net_stats
  expect_equal(st$finish_impact, c(10, 10, 10))
  expect_equal(st$finish_sensitivity, c(1, 1, 1), tolerance = 1e-8)
})

test_that("an inert risk network leaves a seeded run unchanged (G5.9b)", {
  plain <- project_schedule(
    data.frame(id = c("A", "B")),
    data.frame(source = "A", target = "B"),
    duration_dists = list(
      A = list(type = "triangular", a = 1, b = 2, c = 4),
      B = list(type = "pert", a = 2, b = 3, c = 6)
    ),
    resources = data.frame(id = "crew", rate = 10),
    assignments = data.frame(activity = c("A", "B"), resource = "crew", units = 1),
    risks = list(list(id = "R", prob = 0.3, activities = "B",
                      impact = list(type = "uniform", min = 1, max = 2)))
  )
  with_net <- project_schedule(
    plain$activities[c("id", "duration", "fixed_cost")],
    data.frame(source = "A", target = "B"),
    duration_dists = plain$duration_dists,
    resources = data.frame(id = "crew", rate = 10),
    assignments = data.frame(activity = c("A", "B"), resource = "crew", units = 1),
    risks = list(list(id = "R", prob = 0.3, activities = "B",
                      impact = list(type = "uniform", min = 1, max = 2))),
    risk_net = event_net(p1 = 0, p2 = 0),
    risk_effects = list(list(node = "E1", resources = "crew",
                             effect = "productivity", magnitude = fixed_mult(0.5)))
  )
  set.seed(33)
  a <- sra(plain, 500)
  set.seed(33)
  b <- sra(with_net, 500)
  expect_identical(a$total_distribution, b$total_distribution)
  expect_equal(a$cost_distribution, b$cost_distribution)
  expect_null(a$risk_net_stats)
  expect_null(sra(plain, 10, keep_samples = TRUE)$samples$risk_net)
})

test_that("risk-network effects work with leveling and are summarized", {
  p <- project_schedule(
    data.frame(id = c("X", "Y"), duration = c(2, 3)),
    resources = data.frame(id = "crew", capacity = 1, rate = 5),
    assignments = data.frame(activity = c("X", "Y"), resource = "crew", units = 1),
    risk_net = event_net(),
    risk_effects = list(
      list(node = "E1", resources = "crew", effect = "productivity", magnitude = fixed_mult(0.5)),
      list(node = "E2", resources = "crew", effect = "rate", magnitude = fixed_mult(3))
    )
  )
  res <- sra(p, 20, level = TRUE)
  expect_true(all(res$total_distribution == 10))     # (2 + 3) / 0.5, serialized
  expect_true(all(res$cost_distribution == 150))     # 10 periods * 5 * 3
  expect_lte(max(res$resource_profile$crew$p90), 1)
  s <- summary(res)
  expect_equal(nrow(s$risk_net), 3)
  expect_output(print(s), "Risk network nodes")
})
