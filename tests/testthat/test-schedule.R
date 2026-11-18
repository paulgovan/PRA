#' @srrstats {G5.2} *Error and warning behaviour is explicitly demonstrated through tests.*
#' @srrstats {G5.2a} *Every error message is unique and tested.*
#' @srrstats {G5.2b} *Tests trigger every error message and compare with expected values.*
#' @srrstats {G5.8} *Edge condition tests verify appropriate behavior with extreme data properties.*
#' @srrstats {G5.8a} *Zero-length data tests trigger clear errors.*
#' @srrstats {G5.8b} *Unsupported data type tests trigger clear errors.*
#' @srrstats {G5.8c} *All-NA and all-identical data tests trigger clear errors or warnings.*

# A small valid schedule; each test perturbs one argument.
sched_args <- function() {
  list(
    activities = data.frame(
      id = c("A", "B", "C", "D"), duration = c(2, 3, 4, 1),
      fixed_cost = c(10, 0, 0, 5)
    ),
    links = data.frame(
      source = c("A", "A", "B", "C"), target = c("B", "C", "D", "D"),
      type = c("FS", "ss", "FS", "FF"), lag = c(0, 1, 0, 0)
    ),
    duration_dists = list(
      B = list(type = "triangular", a = 2, b = 3, c = 6),
      C = list(type = "pert", a = 3, b = 4, c = 7)
    ),
    resources = data.frame(id = c("crew", "crane"), capacity = c(2, NA), rate = c(100, 50)),
    productivity_dists = list(crew = list(type = "uniform", min = 0.8, max = 1.2)),
    assignments = data.frame(
      activity = c("B", "C", "D"), resource = c("crane", "crew", "crew"),
      units = c(1, 1, 2), work = c(NA, NA, 2)
    ),
    risks = list(list(
      id = "R1", prob = 0.5, activities = "B",
      impact = list(type = "uniform", min = 1, max = 2)
    ))
  )
}

build <- function(args) do.call(project_schedule, args)

expect_sched_error <- function(modify, msg, fixed = TRUE) {
  args <- sched_args()
  args <- modify(args)
  expect_error(build(args), msg, fixed = fixed)
}

test_that("a valid schedule is built and normalized", {
  p <- build(sched_args())
  expect_s3_class(p, "pra_schedule")
  expect_equal(p$activities$id, c("A", "B", "C", "D"))
  expect_equal(p$links$type, c("FS", "SS", "FS", "FF"))
  expect_equal(p$activities$driver, c("fixed", "distribution", "distribution", "resource"))
  # D is resource-driven: work 2 / units 2 at productivity 1.
  expect_equal(p$activities$duration[4], 1)
  expect_equal(p$units["D", "crew"], 2)
  expect_equal(p$adjacency_matrix["A", "B"], 1)
  expect_equal(p$order, 1:4)
  expect_identical(p$time_unit, "periods")
})

test_that("baseline durations default to the distribution's mode or mean", {
  acts <- data.frame(id = c("A", "B", "C", "D"))
  dd <- list(
    A = list(type = "triangular", a = 1, b = 2, c = 5),
    B = list(type = "pert", a = 1, b = 3, c = 5),
    C = list(type = "normal", mean = 4, sd = 1),
    D = list(type = "uniform", min = 2, max = 6)
  )
  p <- project_schedule(acts, duration_dists = dd)
  expect_equal(p$activities$duration, c(2, 3, 4, 4))
  # An explicit duration wins over the distribution's baseline.
  acts$duration <- c(9, NA, NA, NA)
  expect_equal(project_schedule(acts, duration_dists = dd)$activities$duration[1], 9)
})

test_that("a schedule without links, resources or risks is valid", {
  p <- project_schedule(data.frame(id = "only", duration = 3))
  expect_s3_class(p, "pra_schedule")
  expect_equal(nrow(p$links), 0)
  expect_equal(ncol(p$units), 0)
})

test_that("the topological order handles activities listed out of order", {
  p <- project_schedule(
    data.frame(id = c("C", "B", "A"), duration = c(1, 1, 1)),
    data.frame(source = c("A", "B"), target = c("B", "C"))
  )
  expect_equal(p$activities$id[p$order], c("A", "B", "C"))
})

test_that("cycles are rejected and the activities on them named", {
  expect_error(
    project_schedule(
      data.frame(id = c("S", "A", "B", "C", "E"), duration = 1),
      data.frame(
        source = c("S", "A", "B", "C", "C"),
        target = c("A", "B", "C", "A", "E")
      )
    ),
    "The links contain a cycle among activities: A, B, C",
    fixed = TRUE
  )
})

test_that("activities are validated (G5.2b)", {
  expect_sched_error(function(a) { a$activities <- data.frame(); a }, "activities must be a non-empty data frame")
  expect_sched_error(function(a) { a$activities <- list(id = "A"); a }, "activities must be a non-empty data frame")
  expect_sched_error(function(a) { names(a$activities)[1] <- "x"; a }, "activities must contain an 'id' column")
  expect_sched_error(function(a) { a$activities$id[2] <- NA; a }, "activity ids must not be NA")
  expect_sched_error(function(a) { a$activities$id[2] <- ""; a }, "activity ids must not be empty strings")
  expect_sched_error(function(a) { a$activities$id[2] <- "A"; a }, "activity ids must be unique. Duplicated: A")
  expect_sched_error(function(a) { a$activities$duration <- as.character(a$activities$duration); a }, "activity durations must be numeric")
  expect_sched_error(function(a) { a$activities$duration[1] <- NaN; a }, "activity durations must not be NaN")
  expect_sched_error(function(a) { a$activities$duration[1] <- Inf; a }, "activity durations must not be infinite")
  expect_sched_error(function(a) { a$activities$duration[1] <- -1; a }, "activity durations must be non-negative")
  expect_sched_error(function(a) { a$activities$fixed_cost <- "x"; a }, "activity fixed costs must be numeric")
  expect_sched_error(function(a) { a$activities$fixed_cost[1] <- NaN; a }, "activity fixed costs must not be NaN")
  expect_sched_error(function(a) { a$activities$fixed_cost[1] <- NA; a }, "activity fixed costs must not be NA")
  expect_sched_error(function(a) { a$activities$fixed_cost[1] <- Inf; a }, "activity fixed costs must not be infinite")
  expect_sched_error(function(a) { a$activities$fixed_cost[1] <- -1; a }, "activity fixed costs must be non-negative")
  expect_sched_error(function(a) { a$activities$duration[1] <- NA; a }, "Missing for: A")
})

test_that("links are validated (G5.2b)", {
  expect_sched_error(function(a) { a$links <- list(source = "A", target = "B"); a }, "links must be a data frame or NULL")
  expect_sched_error(function(a) { names(a$links)[1] <- "from"; a }, "links must contain 'source' and 'target' columns")
  expect_sched_error(function(a) { a$links$target[1] <- NA; a }, "link sources and targets must not be NA")
  expect_sched_error(function(a) { a$links$target[1] <- "Z"; a }, "Every link source and target must be an activity id. Unknown: Z")
  expect_sched_error(function(a) { a$links$target[1] <- "A"; a }, "links must not contain self-loops")
  expect_sched_error(function(a) { a$links$type[1] <- "XX"; a }, "link types must each be one of 'FS', 'SS', 'FF' or 'SF'")
  expect_sched_error(function(a) { a$links$type[1] <- NA; a }, "link types must each be one of 'FS', 'SS', 'FF' or 'SF'")
  expect_sched_error(function(a) { a$links$lag <- as.character(a$links$lag); a }, "link lags must be numeric")
  expect_sched_error(function(a) { a$links$lag[1] <- NaN; a }, "link lags must not be NaN")
  expect_sched_error(function(a) { a$links$lag[1] <- NA; a }, "link lags must not be NA")
  expect_sched_error(function(a) { a$links$lag[1] <- Inf; a }, "link lags must not be infinite")
  expect_sched_error(function(a) {
    a$links <- rbind(a$links, a$links[1, ])
    a
  }, "links must not repeat the same source, target and type")
})

test_that("an SS and FF link between the same pair is allowed", {
  p <- project_schedule(
    data.frame(id = c("A", "B"), duration = c(4, 4)),
    data.frame(source = "A", target = "B", type = c("SS", "FF"), lag = c(1, 1))
  )
  expect_equal(nrow(p$links), 2)
})

test_that("duration distributions are validated (G5.2b)", {
  expect_sched_error(function(a) { a$duration_dists <- list(list(type = "normal", mean = 1, sd = 1)); a }, "duration_dists must be a list named by activity id")
  expect_sched_error(function(a) { a$duration_dists <- "x"; a }, "duration_dists must be a list named by activity id")
  expect_sched_error(function(a) { names(a$duration_dists)[1] <- "Z"; a }, "duration_dists names must be activity ids. Unknown: Z")
  expect_sched_error(function(a) { names(a$duration_dists)[2] <- "B"; a }, "duration_dists must not name an activity twice")
  lbl <- "duration_dists[['B']]"
  expect_sched_error(function(a) { a$duration_dists$B <- 3; a }, paste(lbl, "must be a list with a 'type' field"))
  expect_sched_error(function(a) { a$duration_dists$B <- list(a = 1); a }, paste(lbl, "must have a single character 'type'"))
  expect_sched_error(function(a) { a$duration_dists$B$type <- "gamma"; a }, paste(lbl, "has unsupported type 'gamma'"))
  expect_sched_error(function(a) { a$duration_dists$B$c <- NULL; a }, paste(lbl, "(triangular) is missing parameter(s): c"))
  expect_sched_error(function(a) { a$duration_dists$B$c <- c(1, 2); a }, paste(lbl, "parameters must each be a single number"))
  expect_sched_error(function(a) { a$duration_dists$B$c <- NaN; a }, paste(lbl, "parameters must not be NaN"))
  expect_sched_error(function(a) { a$duration_dists$B$c <- NA_real_; a }, paste(lbl, "parameters must not be NA"))
  expect_sched_error(function(a) { a$duration_dists$B$c <- Inf; a }, paste(lbl, "parameters must not be infinite"))
  expect_sched_error(function(a) { a$duration_dists$B$c <- 1; a }, paste(lbl, "must satisfy a <= b <= c"))
  expect_sched_error(function(a) { a$duration_dists$B <- list(type = "normal", mean = 3, sd = -1); a }, paste(lbl, "must have a non-negative sd"))
  expect_sched_error(function(a) { a$duration_dists$B <- list(type = "uniform", min = 3, max = 1); a }, paste(lbl, "must satisfy min <= max"))
})

test_that("resources and productivity are validated (G5.2b)", {
  expect_sched_error(function(a) { a$resources <- list(id = "crew"); a }, "resources must be a data frame or NULL")
  expect_sched_error(function(a) { names(a$resources)[1] <- "name"; a }, "resources must contain an 'id' column")
  expect_sched_error(function(a) { a$resources$id[2] <- NA; a }, "resource ids must not be NA")
  expect_sched_error(function(a) { a$resources$id[2] <- ""; a }, "resource ids must not be empty strings")
  expect_sched_error(function(a) { a$resources$id[2] <- "crew"; a }, "resource ids must be unique. Duplicated: crew")
  expect_sched_error(function(a) { a$resources$capacity <- c("a", "b"); a }, "resource capacities must be numeric")
  expect_sched_error(function(a) { a$resources$capacity[1] <- NaN; a }, "resource capacities must not be NaN")
  expect_sched_error(function(a) { a$resources$capacity[1] <- Inf; a }, "resource capacities must not be infinite")
  expect_sched_error(function(a) { a$resources$capacity[1] <- 0; a }, "resource capacities must be positive")
  expect_sched_error(function(a) { a$resources$rate <- c("a", "b"); a }, "resource rates must be numeric")
  expect_sched_error(function(a) { a$resources$rate[1] <- NaN; a }, "resource rates must not be NaN")
  expect_sched_error(function(a) { a$resources$rate[1] <- NA; a }, "resource rates must not be NA")
  expect_sched_error(function(a) { a$resources$rate[1] <- Inf; a }, "resource rates must not be infinite")
  expect_sched_error(function(a) { a$resources$rate[1] <- -5; a }, "resource rates must be non-negative")
  expect_sched_error(function(a) { a$productivity_dists <- list(list(type = "uniform", min = 1, max = 1)); a }, "productivity_dists must be a list named by resource id")
  expect_sched_error(function(a) { names(a$productivity_dists) <- "nobody"; a }, "productivity_dists names must be resource ids. Unknown: nobody")
  expect_sched_error(function(a) { a$productivity_dists$crew <- list(type = "normal", mean = 1, sd = 0.1); a }, "productivity_dists[['crew']] must use a bounded type (triangular, uniform or pert)")
  expect_sched_error(function(a) { a$productivity_dists$crew$min <- 0; a }, "productivity_dists[['crew']] must have a positive minimum")
  expect_sched_error(function(a) { a$productivity_dists$crew$min <- NA_real_; a }, "productivity_dists[['crew']] parameters must not be NA")
})

test_that("assignments are validated (G5.2b)", {
  expect_sched_error(function(a) { a$assignments <- list(activity = "A"); a }, "assignments must be a data frame or NULL")
  expect_sched_error(function(a) { a$assignments$units <- NULL; a }, "assignments must contain 'activity', 'resource' and 'units' columns")
  expect_sched_error(function(a) { a$assignments$resource[1] <- NA; a }, "assignment activities and resources must not be NA")
  expect_sched_error(function(a) { a$assignments$activity[1] <- "Z"; a }, "assignment activities must be activity ids. Unknown: Z")
  expect_sched_error(function(a) { a$assignments$resource[1] <- "robot"; a }, "assignment resources must be resource ids. Unknown: robot")
  expect_sched_error(function(a) { a$assignments$resource[1] <- "crew"; a$assignments$activity[1] <- "C"; a }, "assignments must not repeat an activity-resource pair")
  expect_sched_error(function(a) { a$assignments$units <- c("a", "b", "c"); a }, "assignment units must be numeric")
  expect_sched_error(function(a) { a$assignments$units[1] <- NaN; a }, "assignment units must not be NaN")
  expect_sched_error(function(a) { a$assignments$units[1] <- NA; a }, "assignment units must not be NA")
  expect_sched_error(function(a) { a$assignments$units[1] <- Inf; a }, "assignment units must not be infinite")
  expect_sched_error(function(a) { a$assignments$units[1] <- 0; a }, "assignment units must be positive")
  expect_sched_error(function(a) { a$assignments$work <- c("a", NA, NA); a }, "assignment work must be numeric")
  expect_sched_error(function(a) { a$assignments$work[3] <- NaN; a }, "assignment work must not be NaN")
  expect_sched_error(function(a) { a$assignments$work[3] <- Inf; a }, "assignment work must not be infinite")
  expect_sched_error(function(a) { a$assignments$work[3] <- -2; a }, "assignment work must be positive")
  expect_sched_error(function(a) { a$assignments$units[3] <- 3; a }, "assignment units must not exceed the resource's capacity: D/crew")
  expect_sched_error(function(a) { a$assignments$work[2] <- 8; a }, "Activities cannot have both a duration distribution and work assignments: C")
})

test_that("risks are validated (G5.2b)", {
  expect_sched_error(function(a) { a$risks <- "risk"; a }, "risks must be a list of risk lists or NULL")
  expect_sched_error(function(a) { a$risks <- list("risk"); a }, "risks[[1]] must be a list")
  expect_sched_error(function(a) { a$risks[[1]]$id <- 7; a }, "risks[[1]] id must be a single string")
  expect_sched_error(function(a) { a$risks[[1]]$prob <- NULL; a }, "risks[[1]] must have a 'prob'")
  expect_sched_error(function(a) { a$risks[[1]]$prob <- c(0.1, 0.2); a }, "risks[[1]] prob must be a single number")
  expect_sched_error(function(a) { a$risks[[1]]$prob <- NaN; a }, "risks[[1]] prob must not be NaN")
  expect_sched_error(function(a) { a$risks[[1]]$prob <- NA_real_; a }, "risks[[1]] prob must not be NA")
  expect_sched_error(function(a) { a$risks[[1]]$prob <- 1.5; a }, "risks[[1]] prob must be between 0 and 1")
  expect_sched_error(function(a) { a$risks[[1]]$activities <- character(0); a }, "risks[[1]] must name at least one affected activity")
  expect_sched_error(function(a) { a$risks[[1]]$activities <- "Z"; a }, "risks[[1]] activities must be activity ids. Unknown: Z")
  expect_sched_error(function(a) { a$risks[[1]]$impact <- NULL; a }, "risks[[1]] must have an 'impact' or a 'cost_impact'")
  expect_sched_error(function(a) { a$risks[[1]]$impact$max <- 0; a }, "risks[[1]] impact must satisfy min <= max")
  expect_sched_error(function(a) { a$risks[[1]]$cost_impact <- list(type = "beta"); a }, "risks[[1]] cost_impact has unsupported type 'beta'")
  expect_sched_error(function(a) { a$risks[[2]] <- a$risks[[1]]; a }, "risk ids must be unique")
})

test_that("risk ids default to R<k>", {
  args <- sched_args()
  args$risks[[1]]$id <- NULL
  expect_equal(build(args)$risks[[1]]$id, "R1")
})

test_that("cor_mat, start_date and time_unit are validated (G5.2b)", {
  cm <- matrix(c(1, 0.5, 0.5, 1), 2, dimnames = list(c("C", "B"), c("C", "B")))
  args <- sched_args()
  args$cor_mat <- cm
  p <- build(args)
  # Reordered to the order of names(duration_dists).
  expect_equal(rownames(p$cor_mat), c("B", "C"))

  expect_sched_error(function(a) { a$duration_dists <- NULL; a$cor_mat <- diag(2); a }, "cor_mat requires duration_dists")
  expect_sched_error(function(a) { a$cor_mat <- diag(3); a }, "The correlation matrix must be square and match the number of tasks.")
  expect_sched_error(function(a) { a$cor_mat <- matrix(1, 2, 2); a }, "cor_mat must be positive definite for simulation")
  expect_sched_error(function(a) {
    a$cor_mat <- matrix(c(1, 0, 0, 1), 2, dimnames = list(c("B", "X"), c("B", "X")))
    a
  }, "cor_mat dimnames must match the names of duration_dists")
  expect_sched_error(function(a) { a$start_date <- "not a date"; a }, "start_date must be a single Date")
  expect_sched_error(function(a) { a$start_date <- as.Date(c("2027-01-01", "2027-02-01")); a }, "start_date must be a single Date")
  expect_sched_error(function(a) { a$time_unit <- 3; a }, "time_unit must be a single string")

  args <- sched_args()
  args$start_date <- "2027-01-04"
  expect_equal(build(args)$start_date, as.Date("2027-01-04"))
})

test_that("print and summary describe the schedule (G5.3)", {
  p <- build(sched_args())
  expect_output(expect_invisible(print(p)), "Activities: 4")
  expect_output(print(p), "ASS\\+1")
  s <- summary(p)
  expect_s3_class(s, "summary.pra_schedule")
  expect_equal(s$num_activities, 4)
  expect_equal(s$start_activities, "A")
  expect_equal(s$end_activities, "D")
  expect_equal(s$constrained_resources, "crew")
  expect_true(is.finite(s$deterministic_finish))
  expect_output(expect_invisible(print(s)), "Deterministic finish")
})

# ---- Risk networks feeding resource effects ----

net_args <- function() {
  args <- sched_args()
  args$risk_net <- prob_net(
    data.frame(id = c("Cause", "Shortage")),
    data.frame(source = "Cause", target = "Shortage"),
    list(
      Cause = list(type = "discrete", values = c(1, 0), probs = c(0.3, 0.7)),
      Shortage = list(
        type = "conditional", condition = "Cause",
        true_dist = list(type = "discrete", values = c(1, 0), probs = c(0.9, 0.1)),
        false_dist = list(type = "discrete", values = c(1, 0), probs = c(0.1, 0.9))
      )
    )
  )
  args$risk_effects <- list(
    list(node = "Shortage", resources = c("crew", "crane"), effect = "productivity",
         magnitude = list(type = "triangular", a = 0.6, b = 0.8, c = 0.9)),
    list(node = "Cause", resources = "crew", effect = "rate",
         magnitude = list(type = "uniform", min = 1, max = 1.5))
  )
  args
}

expect_net_error <- function(modify, msg) {
  args <- modify(net_args())
  expect_error(do.call(project_schedule, args), msg, fixed = TRUE)
}

test_that("a risk network and its resource effects are stored", {
  p <- do.call(project_schedule, net_args())
  expect_s3_class(p$risk_net, "prob_net")
  expect_length(p$risk_effects, 2)
  expect_equal(p$risk_effects[[1]]$res_idx, c(1, 2))
  expect_equal(p$risk_effects[[1]]$node_idx, 2)
  expect_output(print(p), "Risk network: 2 nodes, 2 resource effects")
  s <- summary(p)
  expect_equal(s$num_risk_net_nodes, 2)
  expect_equal(s$num_risk_effects, 2)
  expect_output(print(s), "Risk network: 2 nodes, 2 resource effects")
  # A network with no effects is allowed.
  args <- net_args()
  args$risk_effects <- NULL
  expect_length(do.call(project_schedule, args)$risk_effects, 0)
})

test_that("risk networks and effects are validated (G5.2b)", {
  expect_net_error(function(a) { a$risk_net <- list(); a }, "risk_net must be a prob_net object created by prob_net()")
  expect_net_error(function(a) {
    a$risk_net <- prob_net(data.frame(id = "X"), data.frame(source = character(0), target = character(0)))
    a$risk_effects <- NULL
    a
  }, "risk_net must give every node a distribution. Missing: X")
  expect_net_error(function(a) { a$risk_net <- NULL; a }, "risk_effects requires risk_net")
  expect_net_error(function(a) { a$risk_effects <- "x"; a }, "risk_effects must be a list of effect lists or NULL")
  expect_net_error(function(a) { a$risk_effects <- data.frame(node = "Cause"); a }, "risk_effects must be a list of effect lists or NULL")
  expect_net_error(function(a) { a$risk_effects[[1]] <- "x"; a }, "risk_effects[[1]] must be a list")
  expect_net_error(function(a) { a$risk_effects[[1]]$node <- 3; a }, "risk_effects[[1]] node must be a single string")
  expect_net_error(function(a) { a$risk_effects[[1]]$node <- "Z"; a }, "risk_effects[[1]] node must be a risk_net node. Unknown: Z")
  expect_net_error(function(a) { a$risk_effects[[1]]$resources <- character(0); a }, "risk_effects[[1]] must name at least one resource")
  expect_net_error(function(a) { a$risk_effects[[1]]$resources <- "robot"; a }, "risk_effects[[1]] resources must be resource ids. Unknown: robot")
  expect_net_error(function(a) { a$risk_effects[[1]]$effect <- "capacity"; a }, "risk_effects[[1]] effect must be 'productivity' or 'rate'")
  expect_net_error(function(a) { a$risk_effects[[1]]$magnitude <- NULL; a }, "risk_effects[[1]] must have a 'magnitude'")
  expect_net_error(function(a) { a$risk_effects[[1]]$magnitude <- "value"; a }, "risk_effects[[1]] magnitude must be a distribution or the string 'node'")
  expect_net_error(function(a) { a$risk_effects[[1]]$magnitude$c <- 0.1; a }, "risk_effects[[1]] magnitude must satisfy a <= b <= c")
  expect_net_error(function(a) {
    a$risk_effects[[1]]$magnitude <- list(type = "normal", mean = 0.8, sd = 0.1)
    a
  }, "risk_effects[[1]] magnitude must use a bounded type (triangular, uniform or pert)")
  expect_net_error(function(a) { a$risk_effects[[1]]$magnitude$a <- 0; a }, "risk_effects[[1]] magnitude must have a positive minimum for a productivity effect")
  expect_net_error(function(a) { a$risk_effects[[2]]$magnitude$min <- -1; a }, "risk_effects[[2]] magnitude must have a non-negative minimum for a rate effect")
  # A zero rate multiplier is allowed.
  args <- net_args()
  args$risk_effects[[2]]$magnitude$min <- 0
  expect_s3_class(do.call(project_schedule, args), "pra_schedule")
})
