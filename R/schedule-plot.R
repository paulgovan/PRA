# Plot methods for project schedules, critical path results and schedule risk
# analysis results. Drawing primitives live in plot-utils.R.


# Internal: x-axis drawer that labels times as dates when the schedule has a
# start date and a day- or week-based time unit; NULL (numeric axis)
# otherwise. Dates are calendar dates: working calendars are not modelled.
sched_axis_fn <- function(project) {
  sd <- project$start_date
  mult <- switch(tolower(project$time_unit),
    day = , days = 1,
    week = , weeks = 7,
    NULL
  )
  if (is.null(sd) || is.null(mult)) return(NULL)
  function() {
    at <- pretty(graphics::par("usr")[1:2])
    graphics::axis(1, at = at, labels = format(sd + at * mult, "%d %b %Y"),
                   cex.axis = 0.8)
  }
}


# Internal: x-axis label for a time axis.
sched_xlab <- function(project) {
  if (!is.null(sched_axis_fn(project))) return("Date")
  paste0("Time (", project$time_unit, ")")
}


# Internal: draw a schedule's activity-on-node network, left to right, with
# node fills `fill`, node labels `labels`, and links between highlighted
# activities drawn in red. Non-FS links and lags are labelled on the edge.
sched_plot_network <- function(project, fill, labels, main, highlight = NULL,
                               node_cex = 3, label_cex = 0.7, ...) {
  pal <- pra_cols()
  a <- project$adjacency_matrix
  lay <- pra_dag_layout(a, pra_dag_layers(a, project$order), vertical = FALSE)
  lk <- project$links
  # Several links between one pair of activities (an SS/FF ladder, say) are
  # drawn as a single edge carrying all their labels.
  one <- ifelse(lk$type == "FS" & lk$lag == 0, "FS",
    paste0(lk$type, ifelse(lk$lag == 0, "", sprintf("%+g", lk$lag)))
  )
  key <- paste(lk$from_idx, lk$to_idx)
  first <- !duplicated(key)
  edge_label <- vapply(key[first], function(kk) {
    lab <- one[key == kk]
    if (identical(lab, "FS")) "" else paste(lab, collapse = ", ")
  }, character(1), USE.NAMES = FALSE)
  lk <- lk[first, , drop = FALSE]
  edge_col <- rep(unname(pal["ink"]), nrow(lk))
  edge_lwd <- rep(1, nrow(lk))
  if (!is.null(highlight)) {
    hot <- highlight[lk$from_idx] & highlight[lk$to_idx]
    edge_col[hot] <- unname(pal["p95"])
    edge_lwd[hot] <- 2
  }
  pra_plot_dag(lay$x, lay$y,
    from = lk$from_idx, to = lk$to_idx, fill = fill, labels = labels,
    main = main, edge_col = edge_col, edge_label = edge_label,
    edge_lwd = edge_lwd, node_cex = node_cex, label_cex = label_cex, ...
  )
}


#' Plot a project schedule network.
#'
#' Draws the activity-on-node network left to right, layered by longest path
#' from the start. Activities on the deterministic critical path (see [cpm()])
#' and the links between them are drawn in red. Link types other than
#' finish-to-start, and non-zero lags, are labelled on the edge.
#'
#' @param x An object of class `"pra_schedule"`.
#' @param main Optional plot title.
#' @param node_cex,label_cex Node symbol and label sizes.
#' @param ... Additional arguments passed to [graphics::plot()].
#' @return Invisibly returns `x`.
#' @srrstats {G1.4} *Documented with roxygen2.*
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B", "C", "D"), duration = c(3, 5, 4, 2)),
#'   data.frame(
#'     source = c("A", "A", "B", "C"), target = c("B", "C", "D", "D"),
#'     type = c("FS", "SS", "FS", "FS"), lag = c(0, 1, 0, 0)
#'   )
#' )
#' plot(proj)
#' @export
#' @method plot pra_schedule
plot.pra_schedule <- function(x, main = NULL, node_cex = 3, label_cex = 0.7, ...) {
  pal <- pra_cols()
  if (is.null(main)) main <- "Project Schedule Network"
  crit <- cpm(x)$activities$critical
  fill <- ifelse(crit, unname(pal["p95"]), unname(pal["fill"]))
  sched_plot_network(x, fill, x$activities$id, main,
    highlight = crit, node_cex = node_cex, label_cex = label_cex, ...
  )
  graphics::legend("topright",
    legend = c("Critical", "Non-critical"), pt.bg = unname(pal[c("p95", "fill")]),
    pch = 21, col = unname(pal["ink"]), cex = 0.8, bg = "white"
  )
  invisible(x)
}


#' Plot critical path method results.
#'
#' @param x An object of class `"cpm"`.
#' @param type `"gantt"` (default) for a Gantt chart with critical activities
#'   in red and total float as a grey bar, or `"network"` for the
#'   activity-on-node network with the critical path highlighted.
#' @param main Optional plot title.
#' @param ... Additional arguments passed to [graphics::plot()].
#' @return Invisibly returns `x`.
#' @srrstats {G1.4} *Documented with roxygen2.*
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B", "C", "D"), duration = c(3, 5, 4, 2)),
#'   data.frame(source = c("A", "A", "B", "C"), target = c("B", "C", "D", "D"))
#' )
#' res <- cpm(proj)
#' plot(res)
#' plot(res, type = "network")
#' @export
#' @method plot cpm
plot.cpm <- function(x, type = c("gantt", "network"), main = NULL, ...) {
  type <- match.arg(type)
  pal <- pra_cols()
  tab <- x$activities
  p <- x$project
  fill <- ifelse(tab$critical, unname(pal["p95"]), unname(pal["fill"]))
  if (type == "network") {
    if (is.null(main)) main <- "Critical Path Network"
    sched_plot_network(p, fill, tab$id, main, highlight = tab$critical, ...)
    graphics::legend("topright",
      legend = c("Critical", "Non-critical"), pt.bg = unname(pal[c("p95", "fill")]),
      pch = 21, col = unname(pal["ink"]), cex = 0.8, bg = "white"
    )
    return(invisible(x))
  }
  if (is.null(main)) {
    main <- if (x$leveled) "Resource-Leveled Schedule" else "Critical Path Schedule"
  }
  pra_plot_gantt(tab$name, tab$ES, tab$EF, fill,
    main = main, xlab = sched_xlab(p),
    float_end = if (x$leveled) NULL else tab$EF + tab$total_float,
    vline = x$finish, vline_col = unname(pal["ink"]),
    axis_fn = sched_axis_fn(p), ...
  )
  leg <- c("Critical", "Non-critical")
  leg_fill <- unname(pal[c("p95", "fill")])
  leg_col <- c(NA, NA)
  leg_lty <- c(NA, NA)
  if (!x$leveled) {
    leg <- c(leg, "Total float")
    leg_fill <- c(leg_fill, NA)
    leg_col <- c(leg_col, "grey60")
    leg_lty <- c(leg_lty, 1)
  }
  graphics::legend("bottomleft",
    legend = leg, fill = leg_fill, border = NA, col = leg_col,
    lty = leg_lty, lwd = 2, cex = 0.8, bg = "white"
  )
  invisible(x)
}


#' Plot schedule risk analysis results.
#'
#' One method, seven views of a schedule risk analysis:
#' \describe{
#'   \item{`"finish"`}{Histogram of the project finish with P50 and P95
#'     markers and the deterministic finish.}
#'   \item{`"cdf"`}{Cumulative probability (S-curve) of the project finish,
#'     annotated with the deterministic finish and its probability, P50 and
#'     P80.}
#'   \item{`"gantt"`}{Deterministic Gantt bars colored by criticality index,
#'     with P10-P90 finish whiskers and a P50 finish tick for each activity.}
#'   \item{`"tornado"`}{Ranked bar chart of the measure chosen by `metric`.}
#'   \item{`"cost"`}{Cumulative cost S-curve: P50 line and P10-P90 band over
#'     time.}
#'   \item{`"resources"`}{Usage of each resource over time (P50 line and
#'     P10-P90 band) against its capacity.}
#'   \item{`"network"`}{Activity-on-node network with nodes colored by
#'     criticality index.}
#' }
#'
#' @param x An object of class `"sra"`.
#' @param type The view to draw; see Description.
#' @param metric For `type = "tornado"`: `"cruciality"` (default),
#'   `"criticality"`, `"ssi"`, `"sensitivity"`, or `"risk"` for the finish
#'   impact of each risk event.
#' @param resource For `type = "resources"`: resource ids to draw. Defaults
#'   to all resources, one panel each.
#' @param top For `type = "tornado"`: the maximum number of bars. Default 15.
#' @param main Optional plot title.
#' @param ... Additional arguments passed to the underlying plotting function.
#' @return Invisibly returns `x`.
#' @srrstats {G1.4} *Documented with roxygen2.*
#' @examples
#' proj <- project_schedule(
#'   data.frame(id = c("A", "B", "C", "D"), duration = c(3, 5, 4, 2)),
#'   data.frame(source = c("A", "A", "B", "C"), target = c("B", "C", "D", "D")),
#'   duration_dists = list(
#'     B = list(type = "triangular", a = 4, b = 5, c = 9),
#'     C = list(type = "triangular", a = 3, b = 4, c = 8)
#'   ),
#'   resources = data.frame(id = "crew", capacity = 2, rate = 100),
#'   assignments = data.frame(activity = c("B", "C"), resource = "crew", units = 1)
#' )
#' res <- sra(proj, num_sims = 1000)
#' plot(res)
#' plot(res, type = "cdf")
#' plot(res, type = "gantt")
#' plot(res, type = "tornado", metric = "criticality")
#' plot(res, type = "cost")
#' plot(res, type = "resources")
#' plot(res, type = "network")
#' @export
#' @method plot sra
plot.sra <- function(x, type = c("finish", "cdf", "gantt", "tornado", "cost",
                                 "resources", "network"),
                     metric = c("cruciality", "criticality", "ssi",
                                "sensitivity", "risk"),
                     resource = NULL, top = 15, main = NULL, ...) {
  type <- match.arg(type)
  metric <- match.arg(metric)
  pal <- pra_cols()
  p <- x$project
  act <- x$activity_stats
  det <- x$deterministic$finish
  v <- x$total_distribution
  xlab <- sched_xlab(p)
  axis_fn <- sched_axis_fn(p)

  if (type == "finish") {
    if (is.null(main)) main <- "Project Finish Distribution"
    pra_plot_distribution(v,
      mean = x$total_mean, sd = x$total_sd, main = main,
      xlab = paste0("Project finish (", p$time_unit, ")"), normal_fit = FALSE, ...
    )
    graphics::abline(v = det, col = unname(pal["ink"]), lty = 3, lwd = 2)
    graphics::mtext("Deterministic", side = 3, at = det, cex = 0.7, line = 0.2)
  } else if (type == "cdf") {
    if (is.null(main)) main <- "Probability of Finishing By Date"
    s <- sort(v)
    pr <- seq_along(s) / length(s)
    graphics::plot(s, pr,
      type = "s", lwd = 2, col = unname(pal["fill"]), main = main,
      xlab = xlab, ylab = "Cumulative probability", ylim = c(0, 1), xaxt = "n", ...
    )
    if (is.null(axis_fn)) graphics::axis(1) else axis_fn()
    q <- stats::quantile(v, c(0.5, 0.8), names = FALSE)
    graphics::segments(q, 0, q, c(0.5, 0.8), col = unname(pal[c("p50", "p95")]), lty = 2)
    graphics::segments(min(s), c(0.5, 0.8), q, c(0.5, 0.8),
      col = unname(pal[c("p50", "p95")]), lty = 2
    )
    graphics::points(det, x$prob_deterministic, pch = 19, col = unname(pal["ink"]))
    graphics::legend("bottomright",
      legend = c(
        sprintf("Deterministic: %s (P%.0f)", format(signif(det, 4)), 100 * x$prob_deterministic),
        sprintf("P50: %s", format(signif(q[1], 4))),
        sprintf("P80: %s", format(signif(q[2], 4)))
      ),
      col = unname(pal[c("ink", "p50", "p95")]), pch = c(19, NA, NA),
      lty = c(NA, 2, 2), cex = 0.8, bg = "white"
    )
  } else if (type == "gantt") {
    if (is.null(main)) main <- "Schedule Risk: Finish Ranges and Criticality"
    pra_plot_gantt(act$name, act$det_start, act$det_finish,
      pra_crit_cols(act$criticality),
      main = main, xlab = xlab,
      lo = act$finish_p10, mid = act$finish_p50, hi = act$finish_p90,
      vline = c(det, x$percentiles[["80%"]]),
      vline_col = unname(pal[c("ink", "p95")]), axis_fn = axis_fn, ...
    )
    graphics::legend("bottomleft",
      legend = c("Criticality 0%", "50%", "100%", "P10-P90 finish",
                 "Deterministic finish", "P80 finish"),
      fill = c(pra_crit_cols(c(0, 0.5, 1)), NA, NA, NA),
      border = c(NA, NA, NA, NA, NA, NA),
      col = c(NA, NA, NA, unname(pal[c("ink", "ink", "p95")])),
      lty = c(NA, NA, NA, 1, 2, 2), lwd = 1.5, cex = 0.75, bg = "white"
    )
  } else if (type == "tornado") {
    if (metric == "risk") {
      rk <- x$risk_stats
      if (nrow(rk) == 0) {
        message("Nothing to plot: the schedule has no risk events.")
        return(invisible(x))
      }
      vals <- stats::setNames(rk$finish_impact, rk$id)
      lab <- paste0("Mean finish impact (", p$time_unit, ")")
    } else {
      vals <- stats::setNames(act[[metric]], act$id)
      lab <- switch(metric,
        cruciality = "Cruciality index",
        criticality = "Criticality index",
        ssi = "Schedule sensitivity index",
        sensitivity = "Duration sensitivity (Spearman)"
      )
    }
    vals <- vals[!is.na(vals)]
    if (length(vals) == 0) {
      message("Nothing to plot: no activity or risk has a defined value for this metric.")
      return(invisible(x))
    }
    vals <- vals[order(-abs(vals))][seq_len(min(top, length(vals)))]
    if (is.null(main)) main <- paste("Schedule Risk Drivers:", lab)
    op <- graphics::par(mar = c(5, min(max(4, max(nchar(names(vals))) * 0.55 + 1), 15), 4, 2) + 0.1)
    on.exit(graphics::par(op), add = TRUE)
    pra_plot_tornado(vals, main = main, xlab = lab, ...)
  } else if (type == "cost") {
    cc <- x$cost_curve
    if (all(cc$p90 == 0)) {
      message("Nothing to plot: the schedule carries no cost.")
      return(invisible(x))
    }
    if (is.null(main)) main <- "Cumulative Cost S-Curve"
    pra_plot_band(cc$time, cc$p10, cc$p50, cc$p90,
      main = main, xlab = xlab, ylab = "Cumulative cost",
      axis_fn = axis_fn, ...
    )
  } else if (type == "resources") {
    rp <- x$resource_profile
    if (length(rp) == 0) {
      message("Nothing to plot: the schedule has no resources.")
      return(invisible(x))
    }
    if (is.null(resource)) resource <- names(rp)
    bad <- setdiff(resource, names(rp))
    if (length(bad) > 0) {
      stop(paste("Unknown resource(s):", paste(bad, collapse = ", ")))
    }
    if (length(resource) > 1) {
      op <- graphics::par(mfrow = grDevices::n2mfrow(length(resource)))
      on.exit(graphics::par(op), add = TRUE)
    }
    multi <- length(resource) > 1
    for (r in resource) {
      band <- rp[[r]]
      pra_plot_band(band$time, band$p10, band$p50, band$p90,
        main = if (is.null(main)) paste("Resource Usage:", r) else main,
        xlab = xlab, ylab = "Units in use",
        hline = attr(band, "capacity"), step = TRUE, axis_fn = axis_fn,
        legend_cex = if (multi) 0.6 else 0.8, ...
      )
    }
  } else if (type == "network") {
    if (is.null(main)) main <- "Schedule Network by Criticality Index"
    labels <- paste0(act$id, " (", round(100 * act$criticality), "%)")
    sched_plot_network(p, pra_crit_cols(act$criticality), labels, main,
      highlight = act$criticality >= 0.5, ...
    )
    graphics::legend("topright",
      legend = c("Criticality 0%", "50%", "100%"),
      pt.bg = pra_crit_cols(c(0, 0.5, 1)), pch = 21,
      col = unname(pal["ink"]), cex = 0.8, bg = "white"
    )
  }
  invisible(x)
}
