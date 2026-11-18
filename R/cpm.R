# Internal: stop unless `x` is a project schedule.
check_schedule <- function(x) {
  if (!inherits(x, "pra_schedule")) {
    stop("x must be a pra_schedule object created by project_schedule()")
  }
  invisible(TRUE)
}


# Internal: validate a single logical flag argument.
check_flag <- function(v, label) {
  if (!is.logical(v) || length(v) != 1 || is.na(v)) {
    stop(paste(label, "must be a single TRUE or FALSE"))
  }
  invisible(TRUE)
}


#' Critical Path Method.
#'
#' Computes the deterministic schedule of a [project_schedule()] from its
#' baseline durations: early and late start and finish dates, total and free
#' float, and the critical path. All four precedence-diagramming link types
#' (FS, SS, FF, SF) and lags are supported. With `level = TRUE` the schedule is
#' resource-leveled against the capacity of each capacity-limited resource.
#'
#' @details
#' **Forward pass.** Activities are visited in topological order. An activity
#' starts at the latest of time zero and the constraint of each incoming link:
#' `FS`: predecessor finish + lag; `SS`: predecessor start + lag; `FF`:
#' predecessor finish + lag - own duration; `SF`: predecessor start + lag - own
#' duration.
#'
#' **Backward pass.** From the project finish (the latest early finish), each
#' activity's late finish is the earliest of the project finish and the mirror
#' constraint of each outgoing link. Total float is late start minus early
#' start, and an activity is critical when its total float is zero (within a
#' small numerical tolerance). Free float is the slack before an activity
#' delays any successor's early dates.
#'
#' **Resource leveling.** With `level = TRUE` activities are scheduled by the
#' serial schedule-generation scheme (Kolisch, 1996): repeatedly take the
#' eligible activity with the smallest unconstrained late start and place it at
#' the earliest time that satisfies its links and keeps every capacity-limited
#' resource within capacity for the activity's whole duration. Float is not
#' meaningful once resources move dates, so late dates and floats are `NA` and
#' criticality is determined by tracing the *driving path* backward from the
#' project finish through binding links and through resource hand-offs.
#'
#' @param x A `"pra_schedule"` object from [project_schedule()].
#' @param level Logical. Level resources against capacity. Default `FALSE`.
#' @return An S3 object of class `"cpm"`, a list with:
#' \describe{
#'   \item{activities}{Data frame with one row per activity: `id`, `name`,
#'     `duration`, `ES`, `EF`, `LS`, `LF`, `total_float`, `free_float` and
#'     `critical`.}
#'   \item{finish}{Project finish time.}
#'   \item{critical_path}{Ids of critical activities in start order.}
#'   \item{cost}{Deterministic project cost: resource cost plus fixed cost.}
#'   \item{leveled}{Whether the schedule was resource-leveled.}
#'   \item{project}{The input schedule.}
#' }
#' Objects of this class have [print.cpm()], [summary.cpm()] and [plot.cpm()]
#' methods.
#' @references
#' Kelley, James E., and Morgan R. Walker. Critical-path planning and
#' scheduling. Papers presented at the December 1-3, 1959, Eastern Joint IRE-AIEE-ACM
#' Computer Conference (1959): 160-173.
#'
#' Kolisch, Rainer. Serial and parallel resource-constrained project
#' scheduling methods revisited: Theory and computation. European Journal of
#' Operational Research 90.2 (1996): 320-333.
#' @srrstats {G1.0} *Software lists primary references from published academic literature.*
#' @srrstats {G1.4} *Software uses roxygen2 to document all functions.*
#' @srrstats {G2.0} *Asserts that level is a single value.*
#' @srrstats {G2.1} *Asserts the class of x and the type of level.*
#' @srrstats {G2.2} *Prohibits multivariate input to the univariate level argument.*
#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*
#' @examples
#' activities <- data.frame(id = c("A", "B", "C", "D"), duration = c(3, 5, 4, 2))
#' links <- data.frame(
#'   source = c("A", "A", "B", "C"),
#'   target = c("B", "C", "D", "D")
#' )
#' sched <- cpm(project_schedule(activities, links))
#' sched
#' sched$critical_path
#' @export
cpm <- function(x, level = FALSE) {
  check_schedule(x)
  check_flag(level, "level")

  a <- x$activities
  D <- matrix(a$duration, nrow = 1)
  run <- sched_run(D, x, level = level)
  ES <- run$ES[1, ]
  EF <- run$EF[1, ]
  finish <- run$finish[1]
  if (level) {
    LS <- LF <- TF <- FF <- rep(NA_real_, nrow(a))
  } else {
    LS <- run$LS[1, ]
    LF <- run$LF[1, ]
    TF <- run$TF[1, ]
    FF <- sched_free_float(D, run$ES, run$EF, x, run$finish)[1, ]
    tol <- sched_tol(finish)
    TF[abs(TF) <= tol] <- 0
    FF[abs(FF) <= tol] <- 0
  }
  critical <- run$critical[1, ]

  tab <- data.frame(
    id = a$id, name = a$name, duration = a$duration,
    ES = ES, EF = EF, LS = LS, LF = LF,
    total_float = TF, free_float = FF, critical = critical,
    stringsAsFactors = FALSE
  )
  cp <- tab$id[critical][order(ES[critical], EF[critical])]
  cost <- sum(a$fixed_cost + a$duration * sched_cost_rate(x))

  result <- list(
    activities = tab,
    finish = finish,
    critical_path = cp,
    cost = cost,
    leveled = level,
    project = x
  )
  class(result) <- "cpm"
  result
}


#' Print critical path method results.
#'
#' @param x An object of class `"cpm"`.
#' @param digits Number of significant digits for dates. Default 4.
#' @param ... Additional arguments (not used).
#' @return Invisibly returns `x`.
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B", "C"), duration = c(2, 3, 1)),
#'   data.frame(source = c("A", "A"), target = c("B", "C"))
#' )
#' print(cpm(proj))
#' @export
#' @method print cpm
print.cpm <- function(x, digits = 4, ...) {
  cat("Critical Path Method", if (x$leveled) "(resource-leveled)", "\n")
  cat("Project finish:", format(signif(x$finish, digits)), x$project$time_unit, "\n")
  cat("Critical path:", paste(x$critical_path, collapse = " -> "), "\n\n")
  tab <- x$activities
  tab$name <- NULL
  num <- vapply(tab, is.numeric, logical(1))
  tab[num] <- lapply(tab[num], signif, digits = digits)
  if (x$leveled) tab[c("LS", "LF", "total_float", "free_float")] <- NULL
  print(tab, row.names = FALSE)
  invisible(x)
}


#' Summarize critical path method results.
#'
#' @param object An object of class `"cpm"`.
#' @param ... Additional arguments (not used).
#' @return An object of class `"summary.cpm"`, a list with the project finish,
#'   deterministic cost, the critical path, the number of critical activities,
#'   the number of near-critical activities (total float within 10% of the
#'   project duration), and the total and maximum float (`NA` when leveled).
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B", "C"), duration = c(2, 3, 1)),
#'   data.frame(source = c("A", "A"), target = c("B", "C"))
#' )
#' summary(cpm(proj))
#' @export
#' @method summary cpm
summary.cpm <- function(object, ...) {
  tab <- object$activities
  tf <- tab$total_float
  result <- list(
    finish = object$finish,
    cost = object$cost,
    critical_path = object$critical_path,
    num_activities = nrow(tab),
    num_critical = sum(tab$critical),
    num_near_critical = if (object$leveled) NA_integer_ else
      sum(!tab$critical & tf <= 0.1 * object$finish),
    total_float_sum = if (object$leveled) NA_real_ else sum(tf),
    max_float = if (object$leveled) NA_real_ else max(tf),
    leveled = object$leveled,
    time_unit = object$project$time_unit
  )
  class(result) <- "summary.cpm"
  result
}


#' Print a critical path method summary.
#'
#' @param x An object of class `"summary.cpm"`.
#' @param ... Additional arguments (not used).
#' @return Invisibly returns `x`.
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B", "C"), duration = c(2, 3, 1)),
#'   data.frame(source = c("A", "A"), target = c("B", "C"))
#' )
#' print(summary(cpm(proj)))
#' @export
#' @method print summary.cpm
print.summary.cpm <- function(x, ...) {
  cat("Critical Path Method Summary", if (x$leveled) "(resource-leveled)", "\n")
  cat("----------------------------\n")
  cat("Project finish:", format(x$finish), x$time_unit, "\n")
  cat("Deterministic cost:", format(x$cost, big.mark = ",", scientific = FALSE), "\n")
  cat("Critical activities:", x$num_critical, "of", x$num_activities, "\n")
  if (!x$leveled) {
    cat("Near-critical activities (float <= 10% of duration):", x$num_near_critical, "\n")
    cat("Maximum total float:", format(x$max_float), x$time_unit, "\n")
  }
  cat("Critical path:", paste(x$critical_path, collapse = " -> "), "\n")
  invisible(x)
}
