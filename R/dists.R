# Internal helpers for the distribution specifications shared by mcs() and the
# schedule risk analysis functions. A specification is a list with a `type`
# field and that type's parameters:
#   normal     (mean, sd)
#   triangular (a = min, b = mode, c = max)
#   uniform    (min, max)
#   pert       (a = min, b = mode, c = max)   -- schedule functions only
# Specifications are sampled by inverse CDF so that a single code path serves
# both independent draws (u ~ U(0, 1)) and correlated draws (u from a Gaussian
# copula).


# Internal: inverse CDF of a distribution specification at probabilities `u`.
# `allow` lists the types the caller accepts; anything else is an error with the
# message mcs() has always used.
pra_qdist <- function(dist, u, allow = c("normal", "triangular", "uniform", "pert")) {
  type <- dist$type
  if (is.null(type) || !is.character(type) || length(type) != 1 ||
      !type %in% allow) {
    stop("Unsupported distribution type.")
  }
  switch(type,
    normal = stats::qnorm(u, mean = dist$mean, sd = dist$sd),
    triangular = mc2d::qtriang(u, min = dist$a, mode = dist$b, max = dist$c),
    uniform = stats::qunif(u, min = dist$min, max = dist$max),
    pert = mc2d::qpert(u, min = dist$a, mode = dist$b, max = dist$c)
  )
}


# Internal: draw `n` values from a distribution specification. Kept separate
# from pra_qdist() so that independent sampling in mcs() reproduces the exact
# random streams it has always produced.
pra_rdist <- function(dist, n, allow = c("normal", "triangular", "uniform", "pert")) {
  type <- dist$type
  if (is.null(type) || !is.character(type) || length(type) != 1 ||
      !type %in% allow) {
    stop("Unsupported distribution type.")
  }
  switch(type,
    normal = stats::rnorm(n, mean = dist$mean, sd = dist$sd),
    triangular = mc2d::rtriang(n, min = dist$a, mode = dist$b, max = dist$c),
    uniform = stats::runif(n, min = dist$min, max = dist$max),
    pert = mc2d::rpert(n, min = dist$a, mode = dist$b, max = dist$c)
  )
}


# Internal: mean and variance of a distribution specification.
pra_dist_moments <- function(dist) {
  switch(dist$type,
    normal = c(mean = dist$mean, var = dist$sd^2),
    triangular = c(
      mean = (dist$a + dist$b + dist$c) / 3,
      var = (dist$a^2 + dist$b^2 + dist$c^2 - dist$a * dist$b -
        dist$a * dist$c - dist$b * dist$c) / 18
    ),
    uniform = c(
      mean = (dist$min + dist$max) / 2,
      var = (dist$max - dist$min)^2 / 12
    ),
    pert = {
      m <- (dist$a + 4 * dist$b + dist$c) / 6
      c(mean = m, var = (m - dist$a) * (dist$c - m) / 7)
    }
  )
}


# Internal: validate a distribution specification, naming where it came from in
# every message so that errors stay unique and point at the offending input.
# `what` is a label such as "duration_dists[['A']]".
validate_dist_spec <- function(dist, what) {
  if (!is.list(dist)) {
    stop(paste0(what, " must be a list with a 'type' field"))
  }
  type <- dist$type
  if (is.null(type) || !is.character(type) || length(type) != 1) {
    stop(paste0(what, " must have a single character 'type'"))
  }
  params <- switch(type,
    normal = c("mean", "sd"),
    triangular = c("a", "b", "c"),
    uniform = c("min", "max"),
    pert = c("a", "b", "c"),
    stop(paste0(
      what, " has unsupported type '", type,
      "'; use normal, triangular, uniform or pert"
    ))
  )
  missing <- setdiff(params, names(dist))
  if (length(missing) > 0) {
    stop(paste0(
      what, " (", type, ") is missing parameter(s): ",
      paste(missing, collapse = ", ")
    ))
  }
  vals <- dist[params]
  ok_shape <- vapply(vals, function(v) is.numeric(v) && length(v) == 1, logical(1))
  if (!all(ok_shape)) {
    stop(paste0(what, " parameters must each be a single number"))
  }
  vals <- unlist(vals)
  if (any(is.nan(vals))) {
    stop(paste0(what, " parameters must not be NaN"))
  }
  if (anyNA(vals)) {
    stop(paste0(what, " parameters must not be NA"))
  }
  if (any(is.infinite(vals))) {
    stop(paste0(what, " parameters must not be infinite"))
  }
  if (type == "normal" && dist$sd < 0) {
    stop(paste0(what, " must have a non-negative sd"))
  }
  if (type %in% c("triangular", "pert") &&
      !(dist$a <= dist$b && dist$b <= dist$c)) {
    stop(paste0(what, " must satisfy a <= b <= c"))
  }
  if (type == "uniform" && dist$min > dist$max) {
    stop(paste0(what, " must satisfy min <= max"))
  }
  invisible(TRUE)
}
