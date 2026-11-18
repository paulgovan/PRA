#' @srrstats {G5.2} *Error behaviour is explicitly demonstrated through tests.*
#' @srrstats {G5.2b} *Tests trigger every error message and compare with expected values.*
#' @srrstats {G5.3} *Return objects tested for absence of NA, NaN, Inf.*
#' @srrstats {G5.4} *Correctness is checked against hand-solved critical path networks.*
#' @srrstats {G5.6} *Parameter recovery: known early/late dates and floats are recovered exactly.*
#' @srrstats {G5.8} *Edge conditions: zero-duration milestones, single activities, negative lags.*

test_that("CPM reproduces a hand-solved finish-to-start network", {
  # A(3) -> B(4) -> D(5) -> F(2); A -> C(2) -> E(1) -> F.
  p <- project_schedule(
    data.frame(id = LETTERS[1:6], duration = c(3, 4, 2, 5, 1, 2)),
    data.frame(
      source = c("A", "A", "B", "C", "D", "E"),
      target = c("B", "C", "D", "E", "F", "F")
    )
  )
  r <- cpm(p)
  tab <- r$activities
  expect_s3_class(r, "cpm")
  expect_equal(r$finish, 14)
  expect_equal(tab$ES, c(0, 3, 3, 7, 5, 12))
  expect_equal(tab$EF, c(3, 7, 5, 12, 6, 14))
  expect_equal(tab$LS, c(0, 3, 9, 7, 11, 12))
  expect_equal(tab$LF, c(3, 7, 11, 12, 12, 14))
  expect_equal(tab$total_float, c(0, 0, 6, 0, 6, 0))
  # C's float is shared with E, so C has no free float of its own.
  expect_equal(tab$free_float, c(0, 0, 0, 0, 6, 0))
  expect_equal(r$critical_path, c("A", "B", "D", "F"))
  expect_false(anyNA(tab[, c("ES", "EF", "LS", "LF", "total_float", "free_float")]))
})

test_that("SS, FF and SF links with lags are scheduled correctly", {
  p <- project_schedule(
    data.frame(id = c("A", "B", "C", "D"), duration = c(4, 3, 2, 3)),
    data.frame(source = "A", target = c("B", "C", "D"),
               type = c("SS", "FF", "SF"), lag = c(2, 1, 6))
  )
  tab <- cpm(p)$activities
  expect_equal(tab$ES, c(0, 2, 3, 3))   # SS: 0+2; FF: 4+1-2; SF: 0+6-3
  expect_equal(tab$EF, c(4, 5, 5, 6))
  expect_equal(cpm(p)$finish, 6)
  expect_equal(tab$total_float, c(0, 1, 1, 0))
  expect_equal(tab$critical, c(TRUE, FALSE, FALSE, TRUE))
})

test_that("negative lags (leads) overlap activities", {
  p <- project_schedule(
    data.frame(id = c("A", "B"), duration = c(5, 4)),
    data.frame(source = "A", target = "B", lag = -2)
  )
  r <- cpm(p)
  expect_equal(r$activities$ES, c(0, 3))
  expect_equal(r$finish, 7)
  expect_equal(r$activities$total_float, c(0, 0))
})

test_that("an FF link cannot pull a start before time zero", {
  p <- project_schedule(
    data.frame(id = c("A", "B"), duration = c(1, 5)),
    data.frame(source = "A", target = "B", type = "FF")
  )
  r <- cpm(p)
  expect_equal(r$activities$ES, c(0, 0))
  expect_equal(r$finish, 5)
  # A has float: it may finish as late as B's finish.
  expect_equal(r$activities$total_float[1], 4)
})

test_that("SS + FF ladders take the binding constraint", {
  p <- project_schedule(
    data.frame(id = c("A", "B"), duration = c(10, 4)),
    data.frame(source = "A", target = "B", type = c("SS", "FF"), lag = c(2, 1))
  )
  r <- cpm(p)
  # SS gives ES >= 2; FF gives EF >= 11, so ES >= 7.
  expect_equal(r$activities$ES[2], 7)
  expect_equal(r$finish, 11)
})

test_that("zero-duration milestones and single activities work", {
  p <- project_schedule(
    data.frame(id = c("Start", "Work", "Done"), duration = c(0, 5, 0)),
    data.frame(source = c("Start", "Work"), target = c("Work", "Done"))
  )
  r <- cpm(p)
  expect_equal(r$finish, 5)
  expect_equal(r$activities$EF, c(0, 5, 5))
  expect_true(all(r$activities$critical))

  one <- cpm(project_schedule(data.frame(id = "X", duration = 7)))
  expect_equal(one$finish, 7)
  expect_equal(one$critical_path, "X")
})

test_that("deterministic cost is resource cost plus fixed cost", {
  p <- project_schedule(
    data.frame(id = c("A", "B"), duration = c(2, 3), fixed_cost = c(100, 50)),
    data.frame(source = "A", target = "B"),
    resources = data.frame(id = c("r1", "r2"), rate = c(10, 20)),
    assignments = data.frame(activity = c("A", "B", "B"), resource = c("r1", "r1", "r2"),
                             units = c(1, 2, 1))
  )
  # A: 2 * 1 * 10 + 100; B: 3 * (2 * 10 + 1 * 20) + 50.
  expect_equal(cpm(p)$cost, 120 + 170)
})

test_that("resource leveling serializes activities competing for capacity", {
  p <- project_schedule(
    data.frame(id = c("A", "B", "C", "D"), duration = c(1, 3, 2, 1)),
    data.frame(source = c("A", "A", "B", "C"), target = c("B", "C", "D", "D")),
    resources = data.frame(id = "crew", capacity = 1),
    assignments = data.frame(activity = c("B", "C"), resource = "crew", units = 1)
  )
  free <- cpm(p)
  lev <- cpm(p, level = TRUE)
  expect_equal(free$finish, 5)
  expect_equal(lev$finish, 7)
  expect_true(lev$leveled)
  # B has the smaller late start, so it goes first; C waits for the crew.
  expect_equal(lev$activities$ES, c(0, 1, 4, 6))
  # Float is not defined after leveling; the driving path covers all four.
  expect_true(all(is.na(lev$activities$total_float)))
  expect_equal(lev$critical_path, c("A", "B", "C", "D"))
})

test_that("leveling leaves unconstrained or uncontested resources alone", {
  base <- list(
    activities = data.frame(id = c("A", "B"), duration = c(3, 3)),
    assignments = data.frame(activity = c("A", "B"), resource = "crew", units = 1)
  )
  p_unc <- project_schedule(base$activities,
    resources = data.frame(id = "crew"), assignments = base$assignments
  )
  expect_equal(cpm(p_unc, level = TRUE)$finish, 3)
  p_cap2 <- project_schedule(base$activities,
    resources = data.frame(id = "crew", capacity = 2), assignments = base$assignments
  )
  expect_equal(cpm(p_cap2, level = TRUE)$finish, 3)
  p_cap1 <- project_schedule(base$activities,
    resources = data.frame(id = "crew", capacity = 1), assignments = base$assignments
  )
  expect_equal(cpm(p_cap1, level = TRUE)$finish, 6)
})

test_that("leveling fills a gap only when the whole duration fits", {
  # X (higher priority) takes both units of capacity over [1, 3). Y (1 unit)
  # is placed afterwards: a 0.5-long Y fits in the gap before X, but a
  # 1.5-long Y would overlap X, so it waits for X to finish.
  make <- function(dy) {
    project_schedule(
      data.frame(id = c("lead", "X", "Y"), duration = c(1, 2, dy)),
      data.frame(source = "lead", target = "X"),
      resources = data.frame(id = "crew", capacity = 2),
      assignments = data.frame(activity = c("X", "Y"), resource = "crew", units = c(2, 1))
    )
  }
  short <- cpm(make(0.5), level = TRUE)
  expect_equal(short$activities$ES, c(0, 1, 0))
  expect_equal(short$finish, 3)
  long <- cpm(make(1.5), level = TRUE)
  expect_equal(long$activities$ES, c(0, 1, 3))
  expect_equal(long$finish, 4.5)
})

test_that("cpm validates its arguments (G5.2b)", {
  p <- project_schedule(data.frame(id = "A", duration = 1))
  expect_error(cpm(list()), "x must be a pra_schedule object created by project_schedule()", fixed = TRUE)
  expect_error(cpm(p, level = NA), "level must be a single TRUE or FALSE")
  expect_error(cpm(p, level = c(TRUE, FALSE)), "level must be a single TRUE or FALSE")
  expect_error(cpm(p, level = "yes"), "level must be a single TRUE or FALSE")
})

test_that("print and summary report the critical path (G5.3)", {
  p <- project_schedule(
    data.frame(id = c("A", "B", "C"), duration = c(2, 3, 1)),
    data.frame(source = c("A", "A"), target = c("B", "C"))
  )
  r <- cpm(p)
  expect_output(expect_invisible(print(r)), "Critical path: A -> B")
  s <- summary(r)
  expect_s3_class(s, "summary.cpm")
  expect_equal(s$num_critical, 2)
  expect_equal(s$max_float, 2)
  expect_output(expect_invisible(print(s)), "Critical activities: 2 of 3")

  lev <- summary(cpm(p, level = TRUE))
  expect_true(is.na(lev$max_float))
  expect_output(print(lev), "resource-leveled")
  expect_output(print(cpm(p, level = TRUE)), "resource-leveled")
})
