# Internal scheduling engine shared by cpm() and sra().
#
# Activities are indexed 1..n in the order of the `activities` data frame.
# Durations are held as a matrix with one row per iteration and one column per
# activity, so the critical path method passes run across every Monte Carlo
# iteration at once: each activity is visited once, in topological order, and
# its dates are computed as length-`num_sims` vectors. Only resource leveling,
# which is inherently sequential, loops over iterations.


# Internal: numerical tolerance for date comparisons on a schedule whose dates
# reach `horizon`.
sched_tol <- function(horizon) {
  sqrt(.Machine$double.eps) * max(1, abs(horizon), na.rm = TRUE)
}


# Internal: topological order by Kahn's algorithm, preferring the original
# activity order among ready activities so that the order is stable. When the
# links contain a cycle, stop and name the activities on it: nodes that cannot
# reach a cycle are pruned so that only the cyclic core is reported.
sched_topo_order <- function(ids, from, to) {
  n <- length(ids)
  a <- matrix(FALSE, n, n)
  a[cbind(from, to)] <- TRUE
  indeg <- colSums(a)
  done <- logical(n)
  ord <- integer(0)
  for (step in seq_len(n)) {
    ready <- which(!done & indeg == 0)
    if (length(ready) == 0) break
    k <- ready[1]
    done[k] <- TRUE
    ord <- c(ord, k)
    indeg <- indeg - a[k, ]
  }
  if (length(ord) < n) {
    left <- which(!done)
    repeat {
      sub <- a[left, left, drop = FALSE]
      keep <- rowSums(sub) > 0 & colSums(sub) > 0
      if (all(keep)) break
      left <- left[keep]
    }
    stop(paste(
      "The links contain a cycle among activities:",
      paste(ids[left], collapse = ", ")
    ))
  }
  ord
}


# Internal: one link's constraint on its target's early start, given the
# source's early dates and the target's duration (all vectors).
sched_link_es <- function(type, lag, es_i, ef_i, d_j) {
  switch(type,
    FS = ef_i + lag,
    SS = es_i + lag,
    FF = ef_i + lag - d_j,
    SF = es_i + lag - d_j
  )
}


# Internal: forward pass. `D` is an iterations x activities duration matrix.
# Every activity starts no earlier than time 0.
sched_forward <- function(D, x) {
  m <- nrow(D)
  n <- ncol(D)
  ES <- matrix(0, m, n)
  EF <- matrix(0, m, n)
  lk <- x$links
  for (j in x$order) {
    es <- numeric(m)
    for (l in x$pred[[j]]) {
      i <- lk$from_idx[l]
      es <- pmax(es, sched_link_es(lk$type[l], lk$lag[l], ES[, i], EF[, i], D[, j]))
    }
    ES[, j] <- es
    EF[, j] <- es + D[, j]
  }
  list(ES = ES, EF = EF, finish = if (n > 0) apply_rowmax(EF) else numeric(m))
}


# Internal: row maxima without apply() overhead.
apply_rowmax <- function(M) {
  out <- M[, 1]
  if (ncol(M) > 1) {
    for (k in 2:ncol(M)) out <- pmax(out, M[, k])
  }
  out
}


# Internal: backward pass from the project finish `finish` (a vector, one value
# per iteration). Activities with no successors finish no later than the
# project finish.
sched_backward <- function(D, x, finish) {
  m <- nrow(D)
  n <- ncol(D)
  LS <- matrix(0, m, n)
  LF <- matrix(0, m, n)
  lk <- x$links
  for (i in rev(x$order)) {
    lf <- finish
    for (l in x$succ[[i]]) {
      j <- lk$to_idx[l]
      lag <- lk$lag[l]
      cand <- switch(lk$type[l],
        FS = LS[, j] - lag,
        SS = LS[, j] - lag + D[, i],
        FF = LF[, j] - lag,
        SF = LF[, j] - lag + D[, i]
      )
      lf <- pmin(lf, cand)
    }
    LF[, i] <- lf
    LS[, i] <- lf - D[, i]
  }
  list(LS = LS, LF = LF)
}


# Internal: free float of each activity on early dates: how far it can slip
# without delaying any successor's early dates or the project finish.
sched_free_float <- function(D, ES, EF, x, finish) {
  m <- nrow(D)
  n <- ncol(D)
  FF <- matrix(0, m, n)
  lk <- x$links
  for (i in seq_len(n)) {
    ff <- finish - EF[, i]
    for (l in x$succ[[i]]) {
      j <- lk$to_idx[l]
      lag <- lk$lag[l]
      slack <- switch(lk$type[l],
        FS = ES[, j] - lag - EF[, i],
        SS = ES[, j] - lag - ES[, i],
        FF = EF[, j] - lag - EF[, i],
        SF = EF[, j] - lag - ES[, i]
      )
      ff <- pmin(ff, slack)
    }
    FF[, i] <- pmax(ff, 0)
  }
  FF
}


# Internal: resource-constrained schedule for a single iteration by the serial
# schedule-generation scheme. Activities are taken one at a time from those
# whose predecessors are all scheduled, lowest priority value first (ties by
# early start, then activity order), and each is placed at the earliest time
# that satisfies its links and keeps every capacity-limited resource within
# capacity over the whole of its duration. Time is continuous: the candidate
# start times are the precedence-feasible time and every later finish of an
# activity already scheduled, which is where resource usage can drop.
#
# Returns early start/finish vectors plus, for each activity, its
# precedence-feasible start `t0`, used by the driving-path trace.
sched_level_one <- function(d, x, prio, es0) {
  n <- length(d)
  U <- x$units
  cap <- x$resources$capacity
  cr <- which(!is.na(cap))
  lk <- x$links
  es <- rep(NA_real_, n)
  ef <- rep(NA_real_, n)
  t0v <- rep(NA_real_, n)
  scheduled <- logical(n)
  tol <- sched_tol(sum(d) + sum(abs(lk$lag)))

  for (step in seq_len(n)) {
    elig <- which(!scheduled & vapply(x$pred_act, function(p) all(scheduled[p]), logical(1)))
    j <- elig[order(prio[elig], es0[elig], elig)][1]

    t0 <- 0
    for (l in x$pred[[j]]) {
      i <- lk$from_idx[l]
      t0 <- max(t0, sched_link_es(lk$type[l], lk$lag[l], es[i], ef[i], d[j]))
    }

    t <- t0
    need <- cr[U[j, cr] > 0]
    if (length(need) > 0 && d[j] > tol) {
      cands <- sort(unique(c(t0, ef[scheduled & ef > t0])))
      for (t in cands) {
        if (sched_fits(t, d[j], j, need, es, ef, scheduled, U, cap, tol)) break
      }
    }
    es[j] <- t
    ef[j] <- t + d[j]
    t0v[j] <- t0
    scheduled[j] <- TRUE
  }
  list(es = es, ef = ef, t0 = t0v)
}


# Internal: does activity `j` fit at start `t` without exceeding the capacity of
# any resource in `need`? Usage is piecewise constant, so it is enough to check
# it at `t` and at every start of a scheduled activity inside [t, t + dj).
sched_fits <- function(t, dj, j, need, es, ef, scheduled, U, cap, tol) {
  s <- which(scheduled & es < t + dj - tol & ef > t + tol)
  if (length(s) == 0) return(TRUE)
  pts <- c(t, es[s][es[s] > t])
  for (r in need) {
    users <- s[U[s, r] > 0]
    if (length(users) == 0) next
    for (p in pts) {
      active <- users[es[users] <= p + tol & ef[users] > p + tol]
      if (sum(U[active, r]) + U[j, r] > cap[r] + tol) return(FALSE)
    }
  }
  TRUE
}


# Internal: driving-path criticality for a single resource-leveled iteration.
# Starting from the activities that finish the project, walk backward through
# whatever set each activity's start: a binding link, or (when the activity was
# held past its precedence-feasible start) a capacity-sharing activity whose
# finish released the resource at that moment. Float is not meaningful once
# resources move dates, so this trace replaces the zero-float test.
sched_driving <- function(d, es, ef, t0, x) {
  n <- length(d)
  lk <- x$links
  U <- x$units
  cr <- which(!is.na(x$resources$capacity))
  finish <- max(ef)
  tol <- sched_tol(finish)
  crit <- logical(n)
  queue <- which(ef >= finish - tol)
  crit[queue] <- TRUE
  while (length(queue) > 0) {
    j <- queue[1]
    queue <- queue[-1]
    drivers <- integer(0)
    if (es[j] <= t0[j] + tol) {
      for (l in x$pred[[j]]) {
        i <- lk$from_idx[l]
        cand <- sched_link_es(lk$type[l], lk$lag[l], es[i], ef[i], d[j])
        if (cand >= es[j] - tol) drivers <- c(drivers, i)
      }
    } else if (length(cr) > 0) {
      share <- which(rowSums(U[, cr, drop = FALSE] > 0 &
        matrix(U[j, cr] > 0, n, length(cr), byrow = TRUE)) > 0)
      share <- setdiff(share, j)
      drivers <- share[abs(ef[share] - es[j]) <= tol]
    }
    new <- drivers[!crit[drivers]]
    crit[new] <- TRUE
    queue <- c(queue, new)
  }
  crit
}


# Internal: schedule every iteration. `D` is an iterations x activities duration
# matrix. Returns early dates, project finish and a logical criticality matrix.
# Without leveling the passes are fully vectorized and an activity is critical
# when its total float is within tolerance of zero. With leveling, each
# iteration is scheduled by the serial schedule-generation scheme, prioritized
# by that iteration's unconstrained late start, and criticality comes from the
# driving-path trace.
sched_run <- function(D, x, level = FALSE) {
  fw <- sched_forward(D, x)
  bw <- sched_backward(D, x, fw$finish)
  if (!level) {
    TF <- bw$LS - fw$ES
    tol <- sched_tol(max(fw$finish, 0))
    return(list(
      ES = fw$ES, EF = fw$EF, LS = bw$LS, LF = bw$LF, TF = TF,
      finish = fw$finish, critical = TF <= tol
    ))
  }
  m <- nrow(D)
  n <- ncol(D)
  ES <- matrix(0, m, n)
  EF <- matrix(0, m, n)
  crit <- matrix(FALSE, m, n)
  for (k in seq_len(m)) {
    lv <- sched_level_one(D[k, ], x, prio = bw$LS[k, ], es0 = fw$ES[k, ])
    ES[k, ] <- lv$es
    EF[k, ] <- lv$ef
    crit[k, ] <- sched_driving(D[k, ], lv$es, lv$ef, lv$t0, x)
  }
  list(
    ES = ES, EF = EF, LS = NULL, LF = NULL, TF = NULL,
    finish = apply_rowmax(EF), critical = crit
  )
}


# Internal: per-activity cost rate (resource cost per period of duration).
sched_cost_rate <- function(x) {
  if (ncol(x$units) == 0) return(numeric(nrow(x$activities)))
  as.numeric(x$units %*% x$resources$rate)
}


# Internal: cumulative time-phased quantity on a time grid. Each activity's
# amount `A[, j]` is spread linearly over [ES, EF]; a zero-duration activity
# books its whole amount at its start. Returns an iterations x grid matrix.
sched_cumulative <- function(A, ES, EF, grid) {
  m <- nrow(A)
  out <- matrix(0, m, length(grid))
  G <- matrix(grid, m, length(grid), byrow = TRUE)
  for (j in seq_len(ncol(A))) {
    if (all(A[, j] == 0)) next
    dur <- EF[, j] - ES[, j]
    frac <- (G - ES[, j]) / ifelse(dur > 0, dur, 1)
    frac <- pmin(pmax(frac, 0), 1)
    frac[dur <= 0, ] <- (G[dur <= 0, , drop = FALSE] >= ES[dur <= 0, j]) * 1
    out <- out + A[, j] * frac
  }
  out
}


# Internal: resource usage on a time grid for resource column `r`. An activity
# occupies [ES, EF). Returns an iterations x grid matrix.
sched_usage <- function(units_r, ES, EF, grid) {
  m <- nrow(ES)
  out <- matrix(0, m, length(grid))
  G <- matrix(grid, m, length(grid), byrow = TRUE)
  for (j in which(units_r > 0)) {
    out <- out + units_r[j] * ((G >= ES[, j]) & (G < EF[, j]))
  }
  out
}


# Internal: column quantiles of an iterations x grid matrix as a data frame.
sched_band <- function(M, grid, probs = c(0.10, 0.50, 0.90)) {
  q <- apply(M, 2, stats::quantile, probs = probs, names = FALSE)
  q <- matrix(q, nrow = length(probs))
  out <- data.frame(time = grid, mean = colMeans(M))
  for (k in seq_along(probs)) {
    out[[paste0("p", round(probs[k] * 100))]] <- q[k, ]
  }
  out
}
