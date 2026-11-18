# Internal: validate a numeric input column or vector. `label` names the input
# in every message, so messages stay unique across inputs. `bound` is "any",
# "nonneg" or "pos".
check_num_input <- function(v, label, allow_na = FALSE, bound = "any") {
  if (!is.numeric(v)) {
    stop(paste(label, "must be numeric"))
  }
  if (any(is.nan(v))) {
    stop(paste(label, "must not be NaN"))
  }
  if (!allow_na && anyNA(v)) {
    stop(paste(label, "must not be NA"))
  }
  if (any(is.infinite(v))) {
    stop(paste(label, "must not be infinite"))
  }
  w <- v[!is.na(v)]
  if (bound == "nonneg" && any(w < 0)) {
    stop(paste(label, "must be non-negative"))
  }
  if (bound == "pos" && any(w <= 0)) {
    stop(paste(label, "must be positive"))
  }
  invisible(TRUE)
}


# Internal: validate the ids of a data frame's id column.
check_ids <- function(ids, label) {
  if (anyNA(ids)) {
    stop(paste(label, "ids must not be NA"))
  }
  ids <- as.character(ids)
  if (any(ids == "")) {
    stop(paste(label, "ids must not be empty strings"))
  }
  if (anyDuplicated(ids)) {
    stop(paste(
      label, "ids must be unique. Duplicated:",
      paste(unique(ids[duplicated(ids)]), collapse = ", ")
    ))
  }
  ids
}


# Internal: the deterministic (baseline) value of a duration distribution: the
# mode for triangular and PERT, the mean otherwise.
dist_baseline <- function(dist) {
  switch(dist$type,
    triangular = dist$b,
    pert = dist$b,
    normal = dist$mean,
    uniform = (dist$min + dist$max) / 2
  )
}


#' Build a Project Schedule for Critical Path and Schedule Risk Analysis.
#'
#' Assembles and validates a resource-loaded project schedule: activities,
#' precedence links, duration uncertainty, resources with capacities and cost
#' rates, resource assignments, and a register of discrete risk events. The
#' result is the input to [cpm()] (deterministic critical path method) and
#' [sra()] (Monte Carlo schedule risk analysis).
#'
#' @details
#' **Durations.** Every activity needs exactly one duration source:
#' * a fixed `duration` in `activities`;
#' * an entry in `duration_dists` (its `duration`, if also given, is used as
#'   the deterministic baseline; otherwise the baseline is the mode of a
#'   triangular or PERT distribution, or the mean of a normal or uniform one);
#' * work assignments (`work` in `assignments`), in which case the activity is
#'   *resource-driven*: its duration is the longest of `work / (units *
#'   productivity)` across its work assignments, with productivity 1 in the
#'   deterministic baseline. A resource-driven activity cannot also have a
#'   duration distribution; uncertainty enters through `productivity_dists`.
#'
#' **Links.** Precedence links use the precedence diagramming method: `FS`
#' (finish-to-start), `SS` (start-to-start), `FF` (finish-to-finish) and `SF`
#' (start-to-finish), each with a `lag` in time units, which may be negative
#' (a lead). Links must form a directed acyclic graph; a cycle is an error
#' that names the activities on it.
#'
#' **Resources.** A resource with a finite `capacity` is capacity-limited and
#' is respected when scheduling with `level = TRUE` in [cpm()] or [sra()]; a
#' capacity of `NA` means unconstrained. `rate` is cost per unit of resource
#' per time unit, so an assignment costs `units * rate * duration`. No single
#' assignment may need more units than its resource's capacity.
#'
#' **Risks.** Each risk is a list with `id`, `prob` (probability of
#' occurring in an iteration), `activities` (ids it affects), `impact` (a
#' distribution of time added to each affected activity's duration when the
#' risk occurs) and optionally `cost_impact` (a distribution of cost added when
#' it occurs, shared equally among the affected activities for time-phasing).
#'
#' **Distributions.** Distribution specifications use the same format as
#' [mcs()]: a list with a `type` of `"normal"` (`mean`, `sd`), `"triangular"`
#' (`a` = min, `b` = mode, `c` = max), `"uniform"` (`min`, `max`) or `"pert"`
#' (`a`, `b`, `c`, the Beta-PERT distribution). Sampled durations are
#' truncated at zero. Productivity multipliers must use a bounded type
#' (triangular, uniform or PERT) with a positive minimum.
#'
#' @param activities A data frame with one row per activity and columns `id`
#'   (required, unique), `name` (optional label, defaults to `id`), `duration`
#'   (non-negative baseline duration; may be `NA` for activities whose duration
#'   comes from a distribution or work assignments) and `fixed_cost`
#'   (optional non-resource cost, default 0).
#' @param links A data frame of precedence links with columns `source` and
#'   `target` (activity ids), and optional `type` (`"FS"`, `"SS"`, `"FF"` or
#'   `"SF"`, case-insensitive, default `"FS"`) and `lag` (default 0). `NULL`
#'   for a schedule without links.
#' @param duration_dists Optional named list of duration distributions, named
#'   by activity id.
#' @param resources Optional data frame with columns `id` (required),
#'   `capacity` (positive units available, `NA` = unconstrained, default `NA`)
#'   and `rate` (non-negative cost per unit per time unit, default 0).
#' @param productivity_dists Optional named list of productivity multiplier
#'   distributions, named by resource id. A draw of 0.8 makes that resource's
#'   work-driven activities take 1 / 0.8 = 1.25 times longer.
#' @param assignments Optional data frame with columns `activity`, `resource`,
#'   `units` (positive units used per time unit while the activity runs) and
#'   optional `work` (positive total work; `NA` for an assignment that does
#'   not drive duration).
#' @param risks Optional list of risk events; see Details.
#' @param cor_mat Optional correlation matrix among the activities in
#'   `duration_dists`, in the order of `names(duration_dists)` or with
#'   matching dimnames. Must be positive definite. Induced by a Gaussian
#'   copula, as in [mcs()].
#' @param start_date Optional project start `Date` (or a string coercible by
#'   [as.Date()]) used to label plot axes. Time is otherwise measured in
#'   abstract `time_unit`s from zero; calendars are not modelled.
#' @param time_unit Character label for the time unit, such as `"days"` or
#'   `"weeks"`. Used for labels only.
#' @return An S3 object of class `"pra_schedule"`: a list holding the
#'   validated and normalized inputs together with the topological order and
#'   adjacency matrix of the activity network. Objects of this class have
#'   [print.pra_schedule()], [summary.pra_schedule()] and [plot.pra_schedule()]
#'   methods.
#' @references
#' Damnjanovic, Ivan, and Kenneth Reinschmidt. Data analytics for engineering
#' and construction project risk management. Cham, Switzerland: Springer, 2020.
#'
#' Kolisch, Rainer. Serial and parallel resource-constrained project
#' scheduling methods revisited: Theory and computation. European Journal of
#' Operational Research 90.2 (1996): 320-333.
#' @srrstats {G1.0} *Software lists primary references from published academic literature.*
#' @srrstats {G1.4} *Software uses roxygen2 to document all functions.*
#' @srrstats {G2.0} *Implements assertions on lengths of inputs: data frame columns, distribution parameters and correlation matrix dimensions.*
#' @srrstats {G2.0a} *Parameter documentation states the expected input structure.*
#' @srrstats {G2.1} *Implements assertions on types of inputs.*
#' @srrstats {G2.1a} *Parameter documentation states the expected data types.*
#' @srrstats {G2.3a} *Link types are validated against an explicit set of allowed values.*
#' @srrstats {G2.3b} *Link types are matched case-insensitively.*
#' @srrstats {G2.7} *Accepts data frames for tabular inputs.*
#' @srrstats {G2.13} *Implements checks for NA values.*
#' @srrstats {G2.14a} *Errors on missing data with informative messages; NA is accepted only where documented to mean "not supplied".*
#' @srrstats {G2.15} *Implements checks for NaN values.*
#' @srrstats {G2.16} *Implements checks for Inf values.*
#' @srrstats {G3.1} *Correlation among activity durations is user-controlled via cor_mat.*
#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*
#' @examples
#' activities <- data.frame(
#'   id = c("A", "B", "C", "D"),
#'   duration = c(3, 5, 4, 2)
#' )
#' links <- data.frame(
#'   source = c("A", "A", "B", "C"),
#'   target = c("B", "C", "D", "D"),
#'   type = c("FS", "SS", "FS", "FF"),
#'   lag = c(0, 1, 0, 1)
#' )
#' duration_dists <- list(
#'   B = list(type = "triangular", a = 4, b = 5, c = 9),
#'   C = list(type = "pert", a = 3, b = 4, c = 7)
#' )
#' resources <- data.frame(id = "crew", capacity = 1, rate = 1000)
#' assignments <- data.frame(
#'   activity = c("B", "C"), resource = "crew", units = 1
#' )
#' risks <- list(
#'   list(
#'     id = "Late permit", prob = 0.3, activities = "A",
#'     impact = list(type = "uniform", min = 1, max = 3)
#'   )
#' )
#' proj <- project_schedule(activities, links,
#'   duration_dists = duration_dists, resources = resources,
#'   assignments = assignments, risks = risks, time_unit = "days"
#' )
#' proj
#' @export
project_schedule <- function(activities, links = NULL, duration_dists = NULL,
                             resources = NULL, productivity_dists = NULL,
                             assignments = NULL, risks = NULL, cor_mat = NULL,
                             start_date = NULL, time_unit = "periods") {
  # ---- Activities ----
  if (!is.data.frame(activities) || nrow(activities) == 0) {
    stop("activities must be a non-empty data frame")
  }
  if (!"id" %in% names(activities)) {
    stop("activities must contain an 'id' column")
  }
  ids <- check_ids(activities$id, "activity")
  n <- length(ids)
  act_name <- if ("name" %in% names(activities)) {
    nm <- as.character(activities$name)
    ifelse(is.na(nm) | nm == "", ids, nm)
  } else {
    ids
  }
  duration <- if ("duration" %in% names(activities)) activities$duration else rep(NA_real_, n)
  if (all(is.na(duration))) duration <- as.numeric(duration)
  check_num_input(duration, "activity durations", allow_na = TRUE, bound = "nonneg")
  fixed_cost <- if ("fixed_cost" %in% names(activities)) activities$fixed_cost else rep(0, n)
  check_num_input(fixed_cost, "activity fixed costs", bound = "nonneg")

  # ---- Links ----
  if (is.null(links)) {
    links <- data.frame(source = character(0), target = character(0))
  }
  if (!is.data.frame(links)) {
    stop("links must be a data frame or NULL")
  }
  if (!all(c("source", "target") %in% names(links))) {
    stop("links must contain 'source' and 'target' columns")
  }
  src <- as.character(links$source)
  tgt <- as.character(links$target)
  if (anyNA(src) || anyNA(tgt)) {
    stop("link sources and targets must not be NA")
  }
  unknown <- setdiff(c(src, tgt), ids)
  if (length(unknown) > 0) {
    stop(paste(
      "Every link source and target must be an activity id. Unknown:",
      paste(unique(unknown), collapse = ", ")
    ))
  }
  if (any(src == tgt)) {
    stop("links must not contain self-loops")
  }
  ltype <- if ("type" %in% names(links)) toupper(as.character(links$type)) else rep("FS", length(src))
  if (anyNA(ltype) || !all(ltype %in% c("FS", "SS", "FF", "SF"))) {
    stop("link types must each be one of 'FS', 'SS', 'FF' or 'SF'")
  }
  lag <- if ("lag" %in% names(links)) links$lag else rep(0, length(src))
  if (length(src) > 0) check_num_input(lag, "link lags")
  lag <- as.numeric(lag)
  if (anyDuplicated(paste(src, tgt, ltype))) {
    stop("links must not repeat the same source, target and type")
  }
  from_idx <- match(src, ids)
  to_idx <- match(tgt, ids)
  order <- sched_topo_order(ids, from_idx, to_idx)
  links_n <- data.frame(
    source = src, target = tgt, type = ltype, lag = lag,
    from_idx = from_idx, to_idx = to_idx, stringsAsFactors = FALSE
  )
  pred <- lapply(seq_len(n), function(j) which(to_idx == j))
  succ <- lapply(seq_len(n), function(i) which(from_idx == i))
  pred_act <- lapply(pred, function(l) unique(from_idx[l]))
  adj <- matrix(0, n, n, dimnames = list(ids, ids))
  adj[cbind(from_idx, to_idx)] <- 1

  # ---- Duration distributions ----
  if (!is.null(duration_dists)) {
    if (!is.list(duration_dists) || is.null(names(duration_dists)) ||
        any(names(duration_dists) == "")) {
      stop("duration_dists must be a list named by activity id")
    }
    bad <- setdiff(names(duration_dists), ids)
    if (length(bad) > 0) {
      stop(paste(
        "duration_dists names must be activity ids. Unknown:",
        paste(bad, collapse = ", ")
      ))
    }
    if (anyDuplicated(names(duration_dists))) {
      stop("duration_dists must not name an activity twice")
    }
    for (nm in names(duration_dists)) {
      validate_dist_spec(duration_dists[[nm]], paste0("duration_dists[['", nm, "']]"))
    }
  }
  dist_idx <- match(names(duration_dists), ids)

  # ---- Resources ----
  if (is.null(resources)) {
    resources <- data.frame(id = character(0))
  }
  if (!is.data.frame(resources)) {
    stop("resources must be a data frame or NULL")
  }
  if (!"id" %in% names(resources)) {
    stop("resources must contain an 'id' column")
  }
  rids <- check_ids(resources$id, "resource")
  nr <- length(rids)
  capacity <- if ("capacity" %in% names(resources)) resources$capacity else rep(NA_real_, nr)
  if (all(is.na(capacity))) capacity <- as.numeric(capacity)
  check_num_input(capacity, "resource capacities", allow_na = TRUE, bound = "pos")
  rate <- if ("rate" %in% names(resources)) resources$rate else rep(0, nr)
  check_num_input(rate, "resource rates", bound = "nonneg")
  res_n <- data.frame(
    id = rids, capacity = as.numeric(capacity), rate = as.numeric(rate),
    stringsAsFactors = FALSE
  )

  # ---- Productivity distributions ----
  if (!is.null(productivity_dists)) {
    if (!is.list(productivity_dists) || is.null(names(productivity_dists)) ||
        any(names(productivity_dists) == "")) {
      stop("productivity_dists must be a list named by resource id")
    }
    bad <- setdiff(names(productivity_dists), rids)
    if (length(bad) > 0) {
      stop(paste(
        "productivity_dists names must be resource ids. Unknown:",
        paste(bad, collapse = ", ")
      ))
    }
    for (nm in names(productivity_dists)) {
      what <- paste0("productivity_dists[['", nm, "']]")
      validate_dist_spec(productivity_dists[[nm]], what)
      pd <- productivity_dists[[nm]]
      if (identical(pd$type, "normal")) {
        stop(paste(what, "must use a bounded type (triangular, uniform or pert)"))
      }
      lower <- if (pd$type == "uniform") pd$min else pd$a
      if (lower <= 0) {
        stop(paste(what, "must have a positive minimum"))
      }
    }
  }

  # ---- Assignments ----
  units <- matrix(0, n, nr, dimnames = list(ids, rids))
  work <- matrix(NA_real_, n, nr, dimnames = list(ids, rids))
  if (!is.null(assignments)) {
    if (!is.data.frame(assignments)) {
      stop("assignments must be a data frame or NULL")
    }
    if (!all(c("activity", "resource", "units") %in% names(assignments))) {
      stop("assignments must contain 'activity', 'resource' and 'units' columns")
    }
    a_act <- as.character(assignments$activity)
    a_res <- as.character(assignments$resource)
    if (anyNA(a_act) || anyNA(a_res)) {
      stop("assignment activities and resources must not be NA")
    }
    bad <- setdiff(a_act, ids)
    if (length(bad) > 0) {
      stop(paste(
        "assignment activities must be activity ids. Unknown:",
        paste(unique(bad), collapse = ", ")
      ))
    }
    bad <- setdiff(a_res, rids)
    if (length(bad) > 0) {
      stop(paste(
        "assignment resources must be resource ids. Unknown:",
        paste(unique(bad), collapse = ", ")
      ))
    }
    if (anyDuplicated(paste(a_act, a_res, sep = "\r"))) {
      stop("assignments must not repeat an activity-resource pair")
    }
    check_num_input(assignments$units, "assignment units", bound = "pos")
    a_work <- if ("work" %in% names(assignments)) assignments$work else rep(NA_real_, length(a_act))
    if (all(is.na(a_work))) a_work <- as.numeric(a_work)
    check_num_input(a_work, "assignment work", allow_na = TRUE, bound = "pos")
    cells <- cbind(match(a_act, ids), match(a_res, rids))
    units[cells] <- assignments$units
    work[cells] <- a_work
    over <- !is.na(capacity[cells[, 2]]) & assignments$units > capacity[cells[, 2]]
    if (any(over)) {
      stop(paste(
        "assignment units must not exceed the resource's capacity:",
        paste(a_act[over], a_res[over], sep = "/", collapse = ", ")
      ))
    }
  }

  # ---- Duration source per activity ----
  driven <- rowSums(!is.na(work)) > 0
  has_dist <- seq_len(n) %in% dist_idx
  both <- driven & has_dist
  if (any(both)) {
    stop(paste(
      "Activities cannot have both a duration distribution and work",
      "assignments:", paste(ids[both], collapse = ", ")
    ))
  }
  baseline <- as.numeric(duration)
  for (k in seq_along(dist_idx)) {
    j <- dist_idx[k]
    if (is.na(baseline[j])) baseline[j] <- dist_baseline(duration_dists[[k]])
  }
  for (j in which(driven)) {
    w <- !is.na(work[j, ])
    baseline[j] <- max(work[j, w] / units[j, w])
  }
  if (anyNA(baseline)) {
    stop(paste(
      "Every activity needs a duration, a duration distribution or work",
      "assignments. Missing for:", paste(ids[is.na(baseline)], collapse = ", ")
    ))
  }
  driver <- ifelse(driven, "resource", ifelse(has_dist, "distribution", "fixed"))

  # ---- Risks ----
  risks_n <- list()
  if (!is.null(risks)) {
    if (!is.list(risks)) {
      stop("risks must be a list of risk lists or NULL")
    }
    for (k in seq_along(risks)) {
      r <- risks[[k]]
      lbl <- paste0("risks[[", k, "]]")
      if (!is.list(r)) {
        stop(paste(lbl, "must be a list"))
      }
      rid <- if (is.null(r$id)) paste0("R", k) else r$id
      if (!is.character(rid) || length(rid) != 1 || is.na(rid)) {
        stop(paste(lbl, "id must be a single string"))
      }
      if (is.null(r$prob)) {
        stop(paste(lbl, "must have a 'prob'"))
      }
      if (!is.numeric(r$prob) || length(r$prob) != 1) {
        stop(paste(lbl, "prob must be a single number"))
      }
      if (is.nan(r$prob)) stop(paste(lbl, "prob must not be NaN"))
      if (is.na(r$prob)) stop(paste(lbl, "prob must not be NA"))
      if (r$prob < 0 || r$prob > 1) {
        stop(paste(lbl, "prob must be between 0 and 1"))
      }
      ra <- r$activities
      if (is.null(ra) || length(ra) == 0) {
        stop(paste(lbl, "must name at least one affected activity"))
      }
      ra <- as.character(ra)
      bad <- setdiff(ra, ids)
      if (anyNA(ra) || length(bad) > 0) {
        stop(paste(lbl, "activities must be activity ids. Unknown:", paste(bad, collapse = ", ")))
      }
      if (is.null(r$impact) && is.null(r$cost_impact)) {
        stop(paste(lbl, "must have an 'impact' or a 'cost_impact'"))
      }
      if (!is.null(r$impact)) validate_dist_spec(r$impact, paste(lbl, "impact"))
      if (!is.null(r$cost_impact)) validate_dist_spec(r$cost_impact, paste(lbl, "cost_impact"))
      risks_n[[k]] <- list(
        id = rid, prob = r$prob, activities = ra,
        act_idx = match(ra, ids), impact = r$impact, cost_impact = r$cost_impact
      )
    }
    rid_all <- vapply(risks_n, `[[`, character(1), "id")
    if (anyDuplicated(rid_all)) {
      stop("risk ids must be unique")
    }
  }

  # ---- Correlation ----
  if (!is.null(cor_mat)) {
    if (is.null(duration_dists)) {
      stop("cor_mat requires duration_dists")
    }
    validate_cor_mat(cor_mat, length(duration_dists), require_positive_definite = TRUE)
    dn <- dimnames(cor_mat)
    if (!is.null(dn) && !is.null(dn[[1]])) {
      if (!setequal(dn[[1]], names(duration_dists)) ||
          !identical(dn[[1]], dn[[2]])) {
        stop("cor_mat dimnames must match the names of duration_dists")
      }
      cor_mat <- cor_mat[names(duration_dists), names(duration_dists)]
    }
  }

  # ---- Labels ----
  if (!is.null(start_date)) {
    start_date <- tryCatch(as.Date(start_date), error = function(e) NA)
    if (length(start_date) != 1 || is.na(start_date)) {
      stop("start_date must be a single Date")
    }
  }
  if (!is.character(time_unit) || length(time_unit) != 1 || is.na(time_unit)) {
    stop("time_unit must be a single string")
  }

  result <- list(
    activities = data.frame(
      id = ids, name = act_name, duration = baseline,
      fixed_cost = as.numeric(fixed_cost), driver = driver,
      stringsAsFactors = FALSE
    ),
    links = links_n,
    order = order,
    pred = pred,
    succ = succ,
    pred_act = pred_act,
    adjacency_matrix = adj,
    duration_dists = duration_dists,
    dist_idx = dist_idx,
    resources = res_n,
    productivity_dists = productivity_dists,
    units = units,
    work = work,
    risks = risks_n,
    cor_mat = cor_mat,
    start_date = start_date,
    time_unit = time_unit
  )
  class(result) <- "pra_schedule"
  result
}


#' Print a project schedule.
#'
#' @param x An object of class `"pra_schedule"`.
#' @param ... Additional arguments (not used).
#' @return Invisibly returns `x`.
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B"), duration = c(2, 3)),
#'   data.frame(source = "A", target = "B")
#' )
#' print(proj)
#' @export
#' @method print pra_schedule
print.pra_schedule <- function(x, ...) {
  a <- x$activities
  cat("Project Schedule\n")
  cat("Activities:", nrow(a), "  Links:", nrow(x$links),
      "  Resources:", nrow(x$resources), "  Risks:", length(x$risks), "\n")
  cat("Time unit:", x$time_unit)
  if (!is.null(x$start_date)) cat("  Start:", format(x$start_date))
  cat("\n\n")
  show <- data.frame(
    id = a$id, name = a$name, duration = a$duration, driver = a$driver,
    predecessors = vapply(seq_len(nrow(a)), function(j) {
      l <- x$pred[[j]]
      if (length(l) == 0) return("")
      lk <- x$links[l, ]
      lagtxt <- ifelse(lk$lag == 0, "", sprintf("%+g", lk$lag))
      paste0(lk$source, ifelse(lk$type == "FS" & lk$lag == 0, "", lk$type),
             lagtxt, collapse = ", ")
    }, character(1)),
    stringsAsFactors = FALSE
  )
  if (all(show$name == show$id)) show$name <- NULL
  print(show, row.names = FALSE)
  invisible(x)
}


#' Summarize a project schedule.
#'
#' @param object An object of class `"pra_schedule"`.
#' @param ... Additional arguments (not used).
#' @return An object of class `"summary.pra_schedule"`, a list with the
#'   number of activities, links, resources and risks; counts of activities by
#'   duration source; counts of links by type; the start and end activities of
#'   the network; and the deterministic finish and cost from [cpm()].
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B"), duration = c(2, 3)),
#'   data.frame(source = "A", target = "B")
#' )
#' summary(proj)
#' @export
#' @method summary pra_schedule
summary.pra_schedule <- function(object, ...) {
  a <- object$activities
  adj <- object$adjacency_matrix
  det <- cpm(object)
  result <- list(
    num_activities = nrow(a),
    num_links = nrow(object$links),
    num_resources = nrow(object$resources),
    num_risks = length(object$risks),
    drivers = table(factor(a$driver, levels = c("fixed", "distribution", "resource"))),
    link_types = table(factor(object$links$type, levels = c("FS", "SS", "FF", "SF"))),
    start_activities = a$id[colSums(adj) == 0],
    end_activities = a$id[rowSums(adj) == 0],
    constrained_resources = object$resources$id[!is.na(object$resources$capacity)],
    deterministic_finish = det$finish,
    deterministic_cost = det$cost,
    time_unit = object$time_unit
  )
  class(result) <- "summary.pra_schedule"
  result
}


#' Print a project schedule summary.
#'
#' @param x An object of class `"summary.pra_schedule"`.
#' @param ... Additional arguments (not used).
#' @return Invisibly returns `x`.
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B"), duration = c(2, 3)),
#'   data.frame(source = "A", target = "B")
#' )
#' print(summary(proj))
#' @export
#' @method print summary.pra_schedule
print.summary.pra_schedule <- function(x, ...) {
  cat("Project Schedule Summary\n")
  cat("------------------------\n")
  cat("Activities:", x$num_activities, " (fixed:", x$drivers[["fixed"]],
      " distribution:", x$drivers[["distribution"]],
      " resource-driven:", x$drivers[["resource"]], ")\n")
  cat("Links:", x$num_links, " (",
      paste(names(x$link_types), x$link_types, sep = ": ", collapse = "  "), ")\n")
  cat("Resources:", x$num_resources, " (capacity-limited:",
      length(x$constrained_resources), ")\n")
  cat("Risk events:", x$num_risks, "\n")
  cat("Start activities:", paste(x$start_activities, collapse = ", "), "\n")
  cat("End activities:", paste(x$end_activities, collapse = ", "), "\n")
  cat("Deterministic finish:", format(x$deterministic_finish), x$time_unit, "\n")
  cat("Deterministic cost:", format(x$deterministic_cost, big.mark = ",",
                                    scientific = FALSE), "\n")
  invisible(x)
}
