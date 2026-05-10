#' @srrstats {G5.2} Error and warning behaviour explicitly tested.
#' @srrstats {G5.2a} Each unique error message tested at least once.
#' @srrstats {G5.2b} Unique message per stop() call verified by matching text.
#' @srrstats {G5.3} Return objects tested for absence of NA/NaN/Inf.
#' @srrstats {G5.6} Parameter recovery tests confirm distributional outputs.
#' @srrstats {G5.6a} Recovery verified with tolerance appropriate to Monte Carlo.
#' @srrstats {G5.7} Tests run across varying distribution types and sample sizes.
#' @srrstats {G5.8} Edge conditions tested (single node, NULL distributions).
#' @srrstats {G5.9} Noise susceptibility / reproducibility tested with set.seed().
#' @srrstats {G5.9b} Different random seeds produce stable distributional results.

# ── Shared fixtures ────────────────────────────────────────────────────────────

nodes <- data.frame(id = c("A", "B", "C", "D"), stringsAsFactors = FALSE)
links <- data.frame(
  source = c("A", "A", "B", "C"),
  target = c("B", "C", "D", "D"),
  stringsAsFactors = FALSE
)
distributions <- list(
  A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
  B = list(type = "normal", mean = 2, sd = 0.5),
  C = list(
    type = "conditional", condition = "A",
    true_dist  = list(type = "normal",    mean = 1,   sd    = 0.5),
    false_dist = list(type = "lognormal", meanlog = 0, sdlog = 0.2)
  ),
  D = list(type = "aggregate", nodes = c("B", "C"))
)
graph <- prob_net(nodes, links, distributions = distributions)

# ── prob_net() ─────────────────────────────────────────────────────────────────

test_that("prob_net rejects non-data.frame nodes", {
  expect_error(
    prob_net(list(id = "A"), links),
    "Both nodes and links must be data frames."
  )
})

test_that("prob_net rejects non-data.frame links", {
  expect_error(
    prob_net(nodes, list(source = "A", target = "B")),
    "Both nodes and links must be data frames."
  )
})

test_that("prob_net rejects nodes without id column", {
  bad <- data.frame(name = c("A", "B"))
  expect_error(
    prob_net(bad, links),
    "The nodes data frame must contain a column named 'id'."
  )
})

test_that("prob_net rejects links without source/target columns", {
  bad <- data.frame(from = "A", to = "B")
  expect_error(
    prob_net(nodes, bad),
    "The links data frame must contain columns named 'source' and 'target'."
  )
})

test_that("prob_net rejects non-list distributions", {
  expect_error(
    prob_net(nodes, links, distributions = "bad"),
    "Distributions must be a named list"
  )
})

test_that("prob_net rejects distribution missing type", {
  bad_dist <- list(A = list(values = c(0, 1), probs = c(0.5, 0.5)))
  expect_error(
    prob_net(nodes, links, distributions = bad_dist),
    "Each distribution must specify a 'type'."
  )
})

test_that("prob_net rejects discrete distribution missing values/probs", {
  bad_dist <- list(A = list(type = "discrete", values = c(0, 1)))
  expect_error(
    prob_net(nodes, links, distributions = bad_dist),
    "Discrete distributions must have 'values' and 'probs' specified."
  )
})

test_that("prob_net rejects discrete distribution with unequal values/probs lengths", {
  bad_dist <- list(A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.3, 0.2)))
  expect_error(
    prob_net(nodes, links, distributions = bad_dist),
    "'values' and 'probs' must have the same length."
  )
})

test_that("prob_net rejects discrete distribution probs not summing to 1", {
  bad_dist <- list(A = list(type = "discrete", values = c(0, 1), probs = c(0.3, 0.3)))
  expect_error(
    prob_net(nodes, links, distributions = bad_dist),
    "Probabilities in discrete distributions must sum to 1."
  )
})

test_that("prob_net rejects conditional distribution missing required fields", {
  bad_dist <- list(
    A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
    B = list(type = "conditional", condition = "A")
  )
  expect_error(
    prob_net(nodes, links, distributions = bad_dist),
    "Conditional distributions must specify 'condition', 'true_dist', and 'false_dist'."
  )
})

test_that("prob_net rejects conditional referencing non-existent node", {
  bad_dist <- list(
    A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
    B = list(
      type = "conditional", condition = "Z",
      true_dist  = list(type = "normal", mean = 0, sd = 1),
      false_dist = list(type = "normal", mean = 1, sd = 1)
    )
  )
  expect_error(
    prob_net(nodes, links, distributions = bad_dist),
    "The 'condition' must be a discrete or conditional node"
  )
})

test_that("prob_net rejects conditional whose condition is not discrete/conditional", {
  bad_dist <- list(
    A = list(type = "normal", mean = 0, sd = 1),
    B = list(
      type = "conditional", condition = "A",
      true_dist  = list(type = "normal", mean = 0, sd = 1),
      false_dist = list(type = "normal", mean = 1, sd = 1)
    )
  )
  expect_error(
    prob_net(nodes, links, distributions = bad_dist),
    "The 'condition' must be a discrete or conditional node"
  )
})

test_that("prob_net returns a prob_net object with correct structure", {
  expect_s3_class(graph, "prob_net")
  expect_named(graph, c("nodes", "links", "adjacency_matrix", "distributions"))
  expect_identical(graph$nodes, nodes)
  expect_identical(graph$links, links)
  expect_identical(graph$distributions, distributions)
})

test_that("prob_net adjacency matrix has correct dimensions and is symmetric", {
  m <- graph$adjacency_matrix
  n <- nrow(nodes)
  expect_equal(dim(m), c(n, n))
  expect_equal(m, t(m))
})

test_that("prob_net adjacency matrix reflects link counts", {
  m <- graph$adjacency_matrix
  # A→B and A→C: A has two connections to B and C
  expect_equal(m["A", "B"], 1)
  expect_equal(m["A", "C"], 1)
  expect_equal(m["B", "D"], 1)
  expect_equal(m["C", "D"], 1)
  # No direct A→D link
  expect_equal(m["A", "D"], 0)
})

test_that("prob_net works with distributions = NULL", {
  g <- prob_net(nodes, links, distributions = NULL)
  expect_s3_class(g, "prob_net")
  expect_null(g$distributions)
})

test_that("prob_net works with a single-node network (G5.8)", {
  single_node  <- data.frame(id = "X", stringsAsFactors = FALSE)
  single_links <- data.frame(source = character(0), target = character(0))
  g <- prob_net(single_node, single_links)
  expect_s3_class(g, "prob_net")
  expect_equal(dim(g$adjacency_matrix), c(1, 1))
})

test_that("prob_net accepts uniform and lognormal distributions (G5.8)", {
  dist2 <- list(
    A = list(type = "uniform",   min = 0,    max = 1),
    B = list(type = "lognormal", meanlog = 0, sdlog = 1),
    C = list(type = "normal",    mean = 0,    sd = 1),
    D = list(type = "discrete",  values = c(0, 1), probs = c(0.4, 0.6))
  )
  g <- prob_net(nodes, links, distributions = dist2)
  expect_s3_class(g, "prob_net")
})

# ── prob_net_sim() ─────────────────────────────────────────────────────────────

test_that("prob_net_sim rejects non-prob_net input", {
  expect_error(
    prob_net_sim(list()),
    "The network must be a prob_net object."
  )
})

test_that("prob_net_sim errors on node with no distribution", {
  extra_node  <- data.frame(id = c("A", "B", "X"), stringsAsFactors = FALSE)
  extra_links <- data.frame(source = "A", target = "B", stringsAsFactors = FALSE)
  dist_only_ab <- list(
    A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
    B = list(type = "normal", mean = 0, sd = 1)
  )
  g <- prob_net(extra_node, extra_links, distributions = dist_only_ab)
  expect_error(
    prob_net_sim(g),
    "No distribution or probability provided for node"
  )
})

test_that("prob_net_sim errors when conditional node precedes its condition", {
  # Order matters: C depends on A, but here C is listed first
  bad_nodes <- data.frame(id = c("C", "A"), stringsAsFactors = FALSE)
  bad_links <- data.frame(source = "A", target = "C", stringsAsFactors = FALSE)
  bad_dist <- list(
    C = list(
      type = "conditional", condition = "A",
      true_dist  = list(type = "normal", mean = 1, sd = 0.5),
      false_dist = list(type = "normal", mean = 0, sd = 0.5)
    ),
    A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5))
  )
  g <- prob_net(bad_nodes, bad_links, distributions = bad_dist)
  expect_error(
    prob_net_sim(g),
    "Conditional dependency on unsampled node"
  )
})

test_that("prob_net_sim returns a data frame with correct dimensions (G5.3)", {
  set.seed(1)
  result <- prob_net_sim(graph, num_samples = 500)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 500)
  expect_equal(ncol(result), nrow(nodes))
  expect_named(result, nodes$id)
})

test_that("prob_net_sim output contains no NA/NaN/Inf (G5.3)", {
  set.seed(2)
  result <- prob_net_sim(graph, num_samples = 1000)
  expect_false(anyNA(result))
  expect_false(any(sapply(result, function(x) any(is.nan(x)))))
  expect_false(any(sapply(result, function(x) any(is.infinite(x)))))
})

test_that("prob_net_sim aggregate node equals sum of components (G5.6)", {
  set.seed(3)
  result <- prob_net_sim(graph, num_samples = 1000)
  expect_equal(result$D, result$B + result$C)
})

test_that("prob_net_sim normal node recovers mean within tolerance (G5.6a)", {
  set.seed(4)
  result <- prob_net_sim(graph, num_samples = 10000)
  expect_equal(mean(result$B), 2, tolerance = 0.05)
})

test_that("prob_net_sim discrete node recovers expected mean within tolerance (G5.6a)", {
  set.seed(5)
  result <- prob_net_sim(graph, num_samples = 10000)
  expect_equal(mean(result$A), 0.5, tolerance = 0.05)
})

test_that("prob_net_sim lognormal node produces all positive values (G5.7)", {
  lnorm_dist <- list(
    A = list(type = "lognormal", meanlog = 0, sdlog = 0.5),
    B = list(type = "normal", mean = 2, sd = 0.5),
    C = list(type = "normal", mean = 1, sd = 0.5),
    D = list(type = "aggregate", nodes = c("B", "C"))
  )
  g <- prob_net(nodes, links, distributions = lnorm_dist)
  set.seed(6)
  result <- prob_net_sim(g, num_samples = 1000)
  expect_true(all(result$A > 0))
})

test_that("prob_net_sim uniform node produces values within bounds (G5.7)", {
  unif_dist <- list(
    A = list(type = "uniform", min = 2, max = 5),
    B = list(type = "normal",  mean = 2, sd = 0.5),
    C = list(type = "normal",  mean = 1, sd = 0.5),
    D = list(type = "aggregate", nodes = c("B", "C"))
  )
  g <- prob_net(nodes, links, distributions = unif_dist)
  set.seed(7)
  result <- prob_net_sim(g, num_samples = 1000)
  expect_true(all(result$A >= 2 & result$A <= 5))
})

test_that("prob_net_sim is reproducible with set.seed (G5.9)", {
  set.seed(42)
  r1 <- prob_net_sim(graph, num_samples = 500)
  set.seed(42)
  r2 <- prob_net_sim(graph, num_samples = 500)
  expect_equal(r1, r2)
})

# ── prob_net_learn() ───────────────────────────────────────────────────────────

test_that("prob_net_learn rejects non-prob_net input", {
  expect_error(
    prob_net_learn(list()),
    "The network must be a prob_net object."
  )
})

test_that("prob_net_learn errors on unobserved node with no distribution", {
  extra_node  <- data.frame(id = c("A", "B", "X"), stringsAsFactors = FALSE)
  extra_links <- data.frame(source = "A", target = "B", stringsAsFactors = FALSE)
  dist_only_ab <- list(
    A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
    B = list(type = "normal", mean = 0, sd = 1)
  )
  g <- prob_net(extra_node, extra_links, distributions = dist_only_ab)
  expect_error(
    prob_net_learn(g, observations = list()),
    "No distribution or observation provided for node"
  )
})

test_that("prob_net_learn returns data frame with correct dimensions (G5.3)", {
  set.seed(10)
  result <- prob_net_learn(graph, observations = list(A = 1), num_samples = 500)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 500)
  expect_equal(ncol(result), nrow(nodes))
})

test_that("prob_net_learn output contains no NA/NaN/Inf (G5.3)", {
  set.seed(11)
  result <- prob_net_learn(graph, observations = list(A = 1), num_samples = 1000)
  expect_false(anyNA(result))
  expect_false(any(sapply(result, function(x) any(is.nan(x)))))
  expect_false(any(sapply(result, function(x) any(is.infinite(x)))))
})

test_that("prob_net_learn fixes observed node at its observed value", {
  set.seed(12)
  result <- prob_net_learn(graph, observations = list(A = 1), num_samples = 500)
  expect_true(all(result$A == 1))
})

test_that("prob_net_learn with A=1 samples C from true_dist (G5.6)", {
  # When A is always 1, C must come from true_dist (normal, mean=1, sd=0.5).
  # false_dist is lognormal so all values would be positive; true_dist can be negative.
  # Use a large sample and check mean is near 1.
  set.seed(13)
  result <- prob_net_learn(graph, observations = list(A = 1), num_samples = 10000)
  expect_equal(mean(result$C), 1, tolerance = 0.05)
})

test_that("prob_net_learn with A=0 samples C from false_dist (G5.6)", {
  # false_dist is lognormal(meanlog=0, sdlog=0.2); E[X] = exp(0 + 0.04/2) ≈ 1.02
  set.seed(14)
  result <- prob_net_learn(graph, observations = list(A = 0), num_samples = 10000)
  expect_equal(mean(result$C), exp(0 + 0.04 / 2), tolerance = 0.05)
})

test_that("prob_net_learn with empty observations behaves like prob_net_sim", {
  set.seed(15)
  result <- prob_net_learn(graph, observations = list(), num_samples = 500)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 500)
})

# ── prob_net_update() ──────────────────────────────────────────────────────────

test_that("prob_net_update rejects non-prob_net input", {
  expect_error(
    prob_net_update(list()),
    "The graph must be a prob_net object."
  )
})

test_that("prob_net_update rejects add_links without required columns", {
  expect_error(
    prob_net_update(graph, add_links = data.frame(from = "A", to = "D")),
    "add_links must have 'source' and 'target' columns."
  )
})

test_that("prob_net_update rejects remove_links without required columns", {
  expect_error(
    prob_net_update(graph, remove_links = data.frame(from = "A", to = "B")),
    "remove_links must have 'source' and 'target' columns."
  )
})

test_that("prob_net_update rejects non-list update_distributions", {
  expect_error(
    prob_net_update(graph, update_distributions = "bad"),
    "update_distributions must be a named list."
  )
})

test_that("prob_net_update rejects update for non-existent node", {
  expect_error(
    prob_net_update(graph, update_distributions = list(
      Z = list(type = "normal", mean = 0, sd = 1)
    )),
    "Node Z not found in the network nodes."
  )
})

test_that("prob_net_update rejects distribution missing type in update", {
  expect_error(
    prob_net_update(graph, update_distributions = list(
      B = list(mean = 0, sd = 1)
    )),
    "Each distribution must specify a 'type'."
  )
})

test_that("prob_net_update adding a link increases link count", {
  new_link <- data.frame(source = "B", target = "A", stringsAsFactors = FALSE)
  updated  <- prob_net_update(graph, add_links = new_link)
  expect_equal(nrow(updated$links), nrow(links) + 1)
})

test_that("prob_net_update removing a link decreases link count", {
  rm_link <- data.frame(source = "A", target = "B", stringsAsFactors = FALSE)
  updated <- prob_net_update(graph, remove_links = rm_link)
  expect_equal(nrow(updated$links), nrow(links) - 1)
})

test_that("prob_net_update adjacency matrix reflects added link", {
  new_link <- data.frame(source = "A", target = "D", stringsAsFactors = FALSE)
  updated  <- prob_net_update(graph, add_links = new_link)
  expect_equal(updated$adjacency_matrix["A", "D"], 1)
})

test_that("prob_net_update replaces a distribution correctly", {
  new_dist <- list(B = list(type = "lognormal", meanlog = 0, sdlog = 0.5))
  updated  <- prob_net_update(graph, update_distributions = new_dist)
  expect_equal(updated$distributions$B$type, "lognormal")
})

test_that("prob_net_update returns a prob_net object", {
  updated <- prob_net_update(graph)
  expect_s3_class(updated, "prob_net")
})

test_that("prob_net_update removing non-existent link leaves count unchanged (G5.8)", {
  ghost <- data.frame(source = "B", target = "A", stringsAsFactors = FALSE)
  updated <- prob_net_update(graph, remove_links = ghost)
  expect_equal(nrow(updated$links), nrow(links))
})

# ── Integration ────────────────────────────────────────────────────────────────

test_that("full workflow prob_net → sim → learn → update → sim succeeds", {
  g <- prob_net(nodes, links, distributions = distributions)

  set.seed(99)
  sim1 <- prob_net_sim(g, num_samples = 500)
  expect_s3_class(sim1, "data.frame")

  set.seed(99)
  learned <- prob_net_learn(g, observations = list(A = 1), num_samples = 500)
  expect_s3_class(learned, "data.frame")

  new_link <- data.frame(source = "B", target = "A", stringsAsFactors = FALSE)
  g2 <- prob_net_update(g, add_links = new_link,
                         update_distributions = list(
                           B = list(type = "uniform", min = 1, max = 3)
                         ))
  expect_s3_class(g2, "prob_net")

  set.seed(99)
  sim2 <- prob_net_sim(g2, num_samples = 500)
  expect_s3_class(sim2, "data.frame")
  expect_equal(nrow(sim2), 500)
  expect_false(anyNA(sim2))
})
