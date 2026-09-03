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
