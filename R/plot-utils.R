# Shared plotting helpers.
#
# These back both the exported S3 plot methods and the chart images produced by
# the MCP tool layer in tools.R, so the two never drift apart.

#' PRA color palette.
#'
#' @return A named character vector of hex colors.
#' @keywords internal
#' @noRd
pra_cols <- function() {
  c(
    fill = "#18bc9c",
    fill_alpha = "#18bc9c80",
    ink = "#2c3e50",
    p50 = "#3498db",
    p95 = "#e74c3c"
  )
}


#' Plot a simulated total distribution.
#'
#' Histogram of a simulated distribution with an optional moment-matched normal
#' overlay and dashed P50/P95 markers. Shared by [plot.mcs()] and the Monte
#' Carlo MCP tool.
#'
#' @param v Numeric vector of draws.
#' @param mean,sd Moments used for the normal overlay.
#' @param main,xlab Plot labels.
#' @param col Fill color for the histogram bars.
#' @param breaks Passed to [graphics::hist()].
#' @param normal_fit Draw the moment-matched normal curve.
#' @param ... Additional arguments passed to [graphics::hist()].
#' @return Invisibly returns `NULL`.
#' @keywords internal
#' @noRd
pra_plot_distribution <- function(v, mean, sd, main, xlab,
                                  col = NULL, breaks = 50,
                                  normal_fit = TRUE, ...) {
  pal <- pra_cols()
  if (is.null(col)) col <- unname(pal["fill_alpha"])

  graphics::hist(v,
    freq = FALSE, breaks = breaks, main = main, xlab = xlab,
    col = col, border = "white", ...
  )

  # dnorm() is Inf at a zero standard deviation, so only overlay a real curve.
  show_normal <- isTRUE(normal_fit) && is.finite(sd) && sd > 0
  if (show_normal) {
    xs <- seq(min(v), max(v), length.out = 200)
    graphics::lines(xs, stats::dnorm(xs, mean = mean, sd = sd),
      col = unname(pal["ink"]), lwd = 2
    )
  }

  qs <- stats::quantile(v, c(0.50, 0.95))
  graphics::abline(
    v = qs, col = unname(pal[c("p50", "p95")]), lty = 2, lwd = 1.5
  )

  legend_txt <- c("P50", "P95")
  legend_col <- unname(pal[c("p50", "p95")])
  legend_lty <- c(2, 2)
  legend_lwd <- c(1.5, 1.5)
  if (show_normal) {
    legend_txt <- c("Normal fit", legend_txt)
    legend_col <- c(unname(pal["ink"]), legend_col)
    legend_lty <- c(1, legend_lty)
    legend_lwd <- c(2, legend_lwd)
  }
  graphics::legend("topright",
    legend = legend_txt, col = legend_col,
    lty = legend_lty, lwd = legend_lwd, cex = 0.8, bg = "white"
  )
  invisible(NULL)
}


#' Plot a tornado chart of variance shares.
#'
#' @param shares Named numeric vector of contributions.
#' @param main,xlab Plot labels.
#' @param col Optional bar colors; defaults to a green-to-red ramp.
#' @param ... Additional arguments passed to [graphics::barplot()].
#' @return Invisibly returns `NULL`.
#' @keywords internal
#' @noRd
pra_plot_tornado <- function(shares, main, xlab, col = NULL, ...) {
  sorted <- sort(shares)
  if (is.null(col)) {
    col <- grDevices::colorRampPalette(c("#18bc9c", "#e74c3c"))(length(sorted))
  }
  graphics::barplot(sorted,
    horiz = TRUE, las = 1, main = main, xlab = xlab,
    col = col, border = "white", ...
  )
  invisible(NULL)
}


#' Longest-path layers of a directed acyclic graph.
#'
#' @param a Square adjacency matrix with a positive entry for each edge
#'   `[source, target]`.
#' @param order A topological order of the nodes (default: index order).
#' @return Integer vector of layers, 0 for nodes without parents.
#' @keywords internal
#' @noRd
pra_dag_layers <- function(a, order = seq_len(nrow(a))) {
  layer <- integer(nrow(a))
  for (i in order) {
    parents <- which(a[, i] > 0)
    layer[i] <- if (length(parents) == 0) 0L else max(layer[parents]) + 1L
  }
  layer
}


#' Layered layout of a directed acyclic graph.
#'
#' Places nodes by layer and orders them within each layer by alternating
#' downward and upward barycenter sweeps to reduce edge crossings. Shared by
#' [plot.prob_net()] and the schedule network plots.
#'
#' @param a Square adjacency matrix.
#' @param layer Integer layer of each node, from [pra_dag_layers()].
#' @param vertical Layers run top to bottom when `TRUE`, left to right
#'   otherwise.
#' @return A list with numeric vectors `x` and `y`.
#' @keywords internal
#' @noRd
pra_dag_layout <- function(a, layer, vertical = TRUE) {
  n <- nrow(a)
  pos <- rep(NA_real_, n)
  for (lv in sort(unique(layer))) {
    idx <- which(layer == lv)
    pos[idx] <- seq_along(idx) - (length(idx) + 1) / 2
  }
  for (sweep in seq_len(2)) {
    levels_order <- sort(unique(layer))
    if (sweep == 2) levels_order <- rev(levels_order)
    for (lv in levels_order) {
      idx <- which(layer == lv)
      if (length(idx) < 2) next
      bary <- vapply(idx, function(i) {
        neighbours <- if (sweep == 1) which(a[, i] > 0) else which(a[i, ] > 0)
        if (length(neighbours) == 0) pos[i] else mean(pos[neighbours])
      }, numeric(1))
      ord <- order(bary, pos[idx])
      pos[idx[ord]] <- seq_along(idx) - (length(idx) + 1) / 2
    }
  }
  xs <- pos
  ys <- -as.numeric(layer)
  if (!vertical) {
    tmp <- xs
    xs <- -ys
    ys <- tmp
  }
  list(x = xs, y = ys)
}


#' Draw a node-and-arrow graph from a layout.
#'
#' @param xs,ys Node coordinates.
#' @param from,to Integer node indices of each edge.
#' @param fill Node fill colors.
#' @param labels Node labels, drawn below each node.
#' @param main Plot title.
#' @param edge_col Edge colors (recycled).
#' @param edge_label Optional edge labels drawn at edge midpoints.
#' @param edge_lwd Edge line widths (recycled).
#' @param node_cex,label_cex Node symbol and label sizes.
#' @param ... Additional arguments passed to [graphics::plot()].
#' @return Invisibly returns `NULL`.
#' @keywords internal
#' @noRd
pra_plot_dag <- function(xs, ys, from, to, fill, labels, main,
                         edge_col = NULL, edge_label = NULL, edge_lwd = 1,
                         node_cex = 3, label_cex = 0.7, ...) {
  pal <- pra_cols()
  if (is.null(edge_col)) edge_col <- unname(pal["ink"])
  edge_col <- rep(edge_col, length.out = length(from))
  edge_lwd <- rep(edge_lwd, length.out = length(from))

  graphics::plot(xs, ys,
    type = "n", axes = FALSE, xlab = "", ylab = "", main = main,
    xlim = range(xs) + c(-1, 1), ylim = range(ys) + c(-1, 1.2), ...
  )

  # Edges, shortened at both ends so arrowheads land on the node boundary.
  # An edge whose straight line would pass through another node (a link that
  # skips a layer) is drawn as a curve so it is not hidden behind that node.
  radius <- 0.18
  for (k in seq_along(from)) {
    i <- from[k]
    j <- to[k]
    dx <- xs[j] - xs[i]
    dy <- ys[j] - ys[i]
    len <- sqrt(dx^2 + dy^2)
    if (len == 0) next
    ux <- dx / len
    uy <- dy / len
    others <- setdiff(seq_along(xs), c(i, j))
    tproj <- ((xs[others] - xs[i]) * ux + (ys[others] - ys[i]) * uy)
    perp <- abs((xs[others] - xs[i]) * uy - (ys[others] - ys[i]) * ux)
    blocked <- any(tproj > 0 & tproj < len & perp < 0.3)
    if (blocked) {
      # Quadratic Bezier bowed to the side, trimmed at the node boundaries.
      bow <- 0.35 * len
      cx <- (xs[i] + xs[j]) / 2 - uy * bow
      cy <- (ys[i] + ys[j]) / 2 + ux * bow
      tt <- seq(0, 1, length.out = 60)
      bx <- (1 - tt)^2 * xs[i] + 2 * (1 - tt) * tt * cx + tt^2 * xs[j]
      by <- (1 - tt)^2 * ys[i] + 2 * (1 - tt) * tt * cy + tt^2 * ys[j]
      keep <- sqrt((bx - xs[i])^2 + (by - ys[i])^2) >= radius &
        sqrt((bx - xs[j])^2 + (by - ys[j])^2) >= radius
      bx <- bx[keep]
      by <- by[keep]
      nb <- length(bx)
      graphics::lines(bx, by, col = edge_col[k], lwd = edge_lwd[k])
      graphics::arrows(bx[nb - 1], by[nb - 1], bx[nb], by[nb],
        length = 0.08, col = edge_col[k], lwd = edge_lwd[k]
      )
      mx <- bx[ceiling(nb / 2)]
      my <- by[ceiling(nb / 2)]
    } else {
      graphics::arrows(
        xs[i] + ux * radius, ys[i] + uy * radius,
        xs[j] - ux * radius, ys[j] - uy * radius,
        length = 0.08, col = edge_col[k], lwd = edge_lwd[k]
      )
      mx <- (xs[i] + xs[j]) / 2
      my <- (ys[i] + ys[j]) / 2
    }
    if (!is.null(edge_label) && !is.na(edge_label[k]) && edge_label[k] != "") {
      graphics::text(mx, my,
        labels = edge_label[k], cex = label_cex * 0.85,
        col = edge_col[k], pos = 3, offset = 0.2
      )
    }
  }

  graphics::points(xs, ys,
    pch = 21, bg = fill, col = unname(pal["ink"]), cex = node_cex
  )
  graphics::text(xs, ys - 0.4, labels = labels, cex = label_cex)
  invisible(NULL)
}


#' Draw a Gantt chart.
#'
#' Activities run top to bottom in the order given.
#'
#' @param labels Activity labels.
#' @param start,finish Bar start and finish times.
#' @param col Bar fill colors (recycled).
#' @param main,xlab Plot labels.
#' @param float_end Optional end of a thin total-float bar drawn after each
#'   bar (`NA` to skip an activity).
#' @param lo,mid,hi Optional uncertainty whiskers (for example P10, P50 and
#'   P90 finish) drawn across each bar.
#' @param vline Optional vertical reference lines (for example the project
#'   finish).
#' @param vline_col Colors of the reference lines.
#' @param axis_fn Optional function drawing the x axis; the default draws a
#'   numeric axis.
#' @param ... Additional arguments passed to [graphics::plot()].
#' @return Invisibly returns `NULL`.
#' @keywords internal
#' @noRd
pra_plot_gantt <- function(labels, start, finish, col, main, xlab,
                           float_end = NULL, lo = NULL, mid = NULL, hi = NULL,
                           vline = NULL, vline_col = NULL, axis_fn = NULL, ...) {
  pal <- pra_cols()
  n <- length(labels)
  y <- rev(seq_len(n))
  col <- rep(col, length.out = n)

  xmax <- max(c(finish, float_end, hi, vline), na.rm = TRUE)
  xmin <- min(c(0, start, lo), na.rm = TRUE)
  if (xmax <= xmin) xmax <- xmin + 1

  op <- graphics::par(mar = c(
    5, min(max(4, max(nchar(labels)) * 0.55 + 1), 15), 4, 2
  ) + 0.1)
  on.exit(graphics::par(op))

  graphics::plot(NA,
    xlim = c(xmin, xmax), ylim = c(0.4, n + 0.6),
    xlab = xlab, ylab = "", main = main, yaxt = "n", xaxt = "n", ...
  )
  if (is.null(axis_fn)) graphics::axis(1) else axis_fn()
  graphics::axis(2, at = y, labels = labels, las = 1, tick = FALSE, cex.axis = 0.8)
  graphics::abline(h = y, col = "grey92")

  if (!is.null(float_end)) {
    ok <- !is.na(float_end) & float_end > finish
    graphics::segments(finish[ok], y[ok], float_end[ok], y[ok],
      col = "grey60", lwd = 2
    )
  }
  h <- 0.3
  graphics::rect(start, y - h, finish, y + h, col = col, border = "white")
  zero <- finish <= start
  if (any(zero)) {
    graphics::points(start[zero], y[zero], pch = 23, bg = col[zero], cex = 1.4)
  }
  if (!is.null(lo) && !is.null(hi)) {
    graphics::segments(lo, y, hi, y, col = unname(pal["ink"]), lwd = 1.5)
    graphics::segments(lo, y - h / 2, lo, y + h / 2, col = unname(pal["ink"]), lwd = 1.5)
    graphics::segments(hi, y - h / 2, hi, y + h / 2, col = unname(pal["ink"]), lwd = 1.5)
  }
  if (!is.null(mid)) {
    graphics::points(mid, y, pch = 3, col = unname(pal["ink"]), cex = 0.9, lwd = 1.5)
  }
  if (!is.null(vline)) {
    if (is.null(vline_col)) vline_col <- unname(pal["p95"])
    graphics::abline(v = vline, col = vline_col, lty = 2, lwd = 1.5)
  }
  invisible(NULL)
}


#' Draw an uncertainty band over time.
#'
#' A shaded P10-P90 band with the P50 line, and an optional horizontal
#' reference line (for example resource capacity).
#'
#' @param t Time points.
#' @param lo,mid,hi Lower, middle and upper curves.
#' @param main,xlab,ylab Plot labels.
#' @param hline Optional horizontal reference value.
#' @param hline_label Legend text for `hline`.
#' @param step Draw the curves as step functions (for resource usage).
#' @param axis_fn Optional function drawing the x axis.
#' @param legend Draw the legend (headroom is left above the curves for it).
#' @param legend_cex Legend text size.
#' @param ... Additional arguments passed to [graphics::plot()].
#' @return Invisibly returns `NULL`.
#' @keywords internal
#' @noRd
pra_plot_band <- function(t, lo, mid, hi, main, xlab, ylab,
                          hline = NULL, hline_label = "Capacity",
                          step = FALSE, axis_fn = NULL, legend = TRUE,
                          legend_cex = 0.8, ...) {
  pal <- pra_cols()
  ymax <- max(c(hi, hline), na.rm = TRUE)
  if (!is.finite(ymax) || ymax <= 0) ymax <- 1
  # Label large values in thousands or millions so tick labels stay narrow.
  div <- if (ymax >= 1e6) 1e6 else if (ymax >= 1e4) 1e3 else 1
  if (div > 1) ylab <- paste0(ylab, if (div == 1e6) " (millions)" else " (thousands)")
  graphics::plot(NA,
    xlim = range(t), ylim = c(0, ymax * if (!legend) 1.05 else if (legend_cex < 0.8) 1.7 else 1.35),
    main = main, xlab = xlab, ylab = ylab, xaxt = "n", yaxt = "n", ...
  )
  if (is.null(axis_fn)) graphics::axis(1) else axis_fn()
  yat <- pretty(c(0, ymax), n = 4)
  graphics::axis(2, at = yat, labels = format(yat / div, big.mark = ",",
                                              scientific = FALSE, trim = TRUE),
                 las = 1, cex.axis = 0.8)
  if (step) {
    k <- length(t)
    tt <- c(t[1], rep(t[-1], each = 2))
    stepify <- function(v) c(rep(v[-k], each = 2), v[k])
    graphics::polygon(c(tt, rev(tt)), c(stepify(lo), rev(stepify(hi))),
      col = unname(pal["fill_alpha"]), border = NA
    )
    graphics::lines(t, mid, type = "s", col = unname(pal["ink"]), lwd = 2)
  } else {
    graphics::polygon(c(t, rev(t)), c(lo, rev(hi)),
      col = unname(pal["fill_alpha"]), border = NA
    )
    graphics::lines(t, mid, col = unname(pal["ink"]), lwd = 2)
  }
  legend_txt <- c("P50", "P10-P90")
  legend_col <- c(unname(pal["ink"]), NA)
  legend_lty <- c(1, NA)
  legend_fill <- c(NA, unname(pal["fill_alpha"]))
  legend_border <- c(NA, NA)
  if (!is.null(hline) && !is.na(hline)) {
    graphics::abline(h = hline, col = unname(pal["p95"]), lty = 2, lwd = 1.5)
    legend_txt <- c(legend_txt, hline_label)
    legend_col <- c(legend_col, unname(pal["p95"]))
    legend_lty <- c(legend_lty, 2)
    legend_fill <- c(legend_fill, NA)
    legend_border <- c(legend_border, NA)
  }
  if (legend) {
    graphics::legend("topleft",
      legend = legend_txt, col = legend_col, lty = legend_lty, lwd = 2,
      fill = legend_fill, border = legend_border, cex = legend_cex,
      bg = "white", horiz = TRUE
    )
  }
  invisible(NULL)
}


#' Criticality color ramp.
#'
#' @param ci Criticality indices in \[0, 1\].
#' @return Hex colors from green (never critical) through amber to red
#'   (always critical).
#' @keywords internal
#' @noRd
pra_crit_cols <- function(ci) {
  ramp <- grDevices::colorRampPalette(c("#18bc9c", "#f1c40f", "#e74c3c"))(101)
  ci[is.na(ci)] <- 0
  ramp[round(pmin(pmax(ci, 0), 1) * 100) + 1]
}
