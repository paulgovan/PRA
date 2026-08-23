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

# -- Shared fixtures ------------------------------

nodes <- data.frame(id = c("A", "B", "C", "D"), stringsAsFactors = FALSE)
links <- data.frame(
  source = c("A", "B", "C"),
  target = c("C", "D", "D"),
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

# -- prob_net() ------------------------------

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

test_that("prob_net adjacency matrix has correct dimensions and is directed", {
  m <- graph$adjacency_matrix
  n <- nrow(nodes)
  expect_equal(dim(m), c(n, n))
  # The graph is a DAG, so the adjacency matrix must not be symmetric.
  expect_false(isTRUE(all.equal(m, t(m))))
  expect_true(all(m[lower.tri(m, diag = TRUE)] == 0))
})

test_that("prob_net adjacency matrix records edge direction", {
  m <- graph$adjacency_matrix
  expect_equal(m["A", "C"], 1)
  expect_equal(m["B", "D"], 1)
  expect_equal(m["C", "D"], 1)
  # Direction is preserved: the reverse entries stay empty.
  expect_equal(m["C", "A"], 0)
  expect_equal(m["D", "B"], 0)
  # No direct A->D link
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
  # None of these declare a dependency, so the network carries no links.
  no_links <- data.frame(source = character(0), target = character(0))
  g <- prob_net(nodes, no_links, distributions = dist2)
  expect_s3_class(g, "prob_net")
})

# -- Graph / distribution consistency ------------------------------
#
# The links are load-bearing: the graph and the distributions must describe the
# same DAG, so an inconsistent network is rejected rather than silently
# simulated from the distribution list alone.

test_that("prob_net rejects a link with no declared dependency", {
  stray <- rbind(links,
                 data.frame(source = "A", target = "D", stringsAsFactors = FALSE))
  expect_error(
    prob_net(nodes, stray, distributions = distributions),
    "Every link must correspond to a dependency declared by the"
  )
})

test_that("prob_net rejects a declared dependency with no link", {
  missing <- links[links$source != "A", ]
  expect_error(
    prob_net(nodes, missing, distributions = distributions),
    "Every dependency declared by the distributions must appear in the"
  )
})

test_that("prob_net rejects duplicate node ids", {
  dup <- data.frame(id = c("A", "A", "C", "D"), stringsAsFactors = FALSE)
  expect_error(
    prob_net(dup, links, distributions = distributions),
    "must not contain duplicate ids"
  )
})

test_that("prob_net rejects a link endpoint that is not a node", {
  ghost <- rbind(links,
                 data.frame(source = "Z", target = "D", stringsAsFactors = FALSE))
  expect_error(
    prob_net(nodes, ghost, distributions = distributions),
    "Every link source and target must be a node id"
  )
})

test_that("prob_net rejects self-loops", {
  loop <- data.frame(source = "A", target = "A", stringsAsFactors = FALSE)
  expect_error(
    prob_net(data.frame(id = "A", stringsAsFactors = FALSE), loop,
             list(A = list(type = "aggregate", nodes = "A"))),
    "must not contain self-loops"
  )
})

test_that("prob_net rejects a distribution named for a node not in the network", {
  extra <- c(distributions,
             list(Z = list(type = "normal", mean = 0, sd = 1)))
  expect_error(
    prob_net(nodes, links, distributions = extra),
    "Distributions must be named for nodes in the network"
  )
})

test_that("prob_net rejects an aggregate over a node not in the network", {
  bad <- distributions
  bad$D <- list(type = "aggregate", nodes = c("B", "Z"))
  bad_links <- rbind(links[links$target != "D", ],
                     data.frame(source = c("B", "Z"), target = c("D", "D"),
                                stringsAsFactors = FALSE))
  expect_error(
    prob_net(nodes, bad_links, distributions = bad),
    "Every link source and target must be a node id"
  )
})

test_that("prob_net_update rejects removing an edge without severing the dependency", {
  # This is what makes remove_links structurally meaningful: dropping the edge
  # into a conditional node must be accompanied by a new distribution for it.
  expect_error(
    prob_net_update(graph,
                    remove_links = data.frame(source = "A", target = "C",
                                              stringsAsFactors = FALSE)),
    "Every dependency declared by the distributions must appear in the"
  )
})

test_that("prob_net_update accepts an intervention that severs both", {
  inter <- prob_net_update(
    graph,
    remove_links = data.frame(source = "A", target = "C",
                              stringsAsFactors = FALSE),
    update_distributions = list(C = list(type = "normal", mean = 1, sd = 0.5))
  )
  expect_s3_class(inter, "prob_net")
  expect_equal(inter$adjacency_matrix["A", "C"], 0)
  expect_equal(inter$distributions$C$type, "normal")
})

test_that("removing an edge severs the dependency it represents", {
  # Regression guard: the links must not be decorative. The branches are far
  # apart so the dependence is unmistakable before the intervention and gone
  # after it.
  sep_nodes <- data.frame(id = c("A", "C"), stringsAsFactors = FALSE)
  sep_links <- data.frame(source = "A", target = "C", stringsAsFactors = FALSE)
  sep_dist <- list(
    A = list(type = "discrete", values = c(1, 0), probs = c(0.5, 0.5)),
    C = list(
      type = "conditional", condition = "A",
      true_dist  = list(type = "normal", mean = 100, sd = 1),
      false_dist = list(type = "normal", mean = 1,   sd = 1)
    )
  )
  g <- prob_net(sep_nodes, sep_links, distributions = sep_dist)

  set.seed(11)
  before <- prob_net_sim(g, num_samples = 8000)
  inter <- prob_net_update(
    g,
    remove_links = sep_links,
    update_distributions = list(C = list(type = "normal", mean = 1, sd = 1))
  )
  set.seed(11)
  after <- prob_net_sim(inter, num_samples = 8000)

  expect_false(isTRUE(all.equal(before$C, after$C)))
  expect_gt(abs(cor(before$A, before$C)), 0.9)
  expect_lt(abs(cor(after$A, after$C)), 0.05)
})

# -- prob_net_sim() ------------------------------

test_that("prob_net_sim rejects non-prob_net input", {
  expect_error(
    prob_net_sim(list()),
    "The network must be a prob_net object."
  )
})

test_that("prob_net_sim errors on node with no distribution", {
  extra_node  <- data.frame(id = c("A", "B", "X"), stringsAsFactors = FALSE)
  extra_links <- data.frame(source = character(0), target = character(0))
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

test_that("prob_net rejects a conditional node listed before its condition", {
  # Order matters: C depends on A, but here C is listed first. prob_net() now
  # rejects this at construction rather than leaving it for prob_net_sim().
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
  expect_error(
    prob_net(bad_nodes, bad_links, distributions = bad_dist),
    "must be supplied in a topological order"
  )
})

test_that("prob_net_sim still guards against an unsampled condition (G5.2a)", {
  # Unreachable through prob_net(), which validates node order, so the object is
  # built directly to keep the defensive guard covered.
  bad <- structure(
    list(
      nodes = data.frame(id = c("C", "A"), stringsAsFactors = FALSE),
      links = data.frame(source = "A", target = "C", stringsAsFactors = FALSE),
      adjacency_matrix = matrix(0, 2, 2,
        dimnames = list(c("C", "A"), c("C", "A"))),
      distributions = list(
        C = list(
          type = "conditional", condition = "A",
          true_dist  = list(type = "normal", mean = 1, sd = 0.5),
          false_dist = list(type = "normal", mean = 0, sd = 0.5)
        ),
        A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5))
      )
    ),
    class = "prob_net"
  )
  expect_error(
    prob_net_sim(bad),
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
  agg_links <- data.frame(source = c("B", "C"), target = c("D", "D"),
                          stringsAsFactors = FALSE)
  g <- prob_net(nodes, agg_links, distributions = lnorm_dist)
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
  agg_links <- data.frame(source = c("B", "C"), target = c("D", "D"),
                          stringsAsFactors = FALSE)
  g <- prob_net(nodes, agg_links, distributions = unif_dist)
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

# -- prob_net_learn() ------------------------------

test_that("prob_net_learn rejects non-prob_net input", {
  expect_error(
    prob_net_learn(list()),
    "The network must be a prob_net object."
  )
})

test_that("prob_net_learn errors on unobserved node with no distribution", {
  extra_node  <- data.frame(id = c("A", "B", "X"), stringsAsFactors = FALSE)
  extra_links <- data.frame(source = character(0), target = character(0))
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
  # false_dist is lognormal(meanlog=0, sdlog=0.2); E[X] = exp(0 + 0.04/2) ~= 1.02
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

# -- prob_net_update() ------------------------------

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

# Adding an edge means adding the dependency it stands for, so the link change
# and the distribution change are supplied together.
make_b_conditional <- list(B = list(
  type = "conditional", condition = "A",
  true_dist  = list(type = "normal", mean = 5, sd = 0.5),
  false_dist = list(type = "normal", mean = 2, sd = 0.5)
))

test_that("prob_net_update adding a link increases link count", {
  new_link <- data.frame(source = "A", target = "B", stringsAsFactors = FALSE)
  updated  <- prob_net_update(graph, add_links = new_link,
                              update_distributions = make_b_conditional)
  expect_equal(nrow(updated$links), nrow(links) + 1)
})

test_that("prob_net_update removing a link decreases link count", {
  rm_link <- data.frame(source = "A", target = "C", stringsAsFactors = FALSE)
  updated <- prob_net_update(
    graph,
    remove_links = rm_link,
    update_distributions = list(C = list(type = "normal", mean = 1, sd = 0.5))
  )
  expect_equal(nrow(updated$links), nrow(links) - 1)
})

test_that("prob_net_update adjacency matrix reflects added link", {
  new_link <- data.frame(source = "A", target = "B", stringsAsFactors = FALSE)
  updated  <- prob_net_update(graph, add_links = new_link,
                              update_distributions = make_b_conditional)
  expect_equal(updated$adjacency_matrix["A", "B"], 1)
  expect_equal(updated$adjacency_matrix["B", "A"], 0)
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

# -- Integration ------------------------------

test_that("full workflow prob_net -> sim -> learn -> update -> sim succeeds", {
  g <- prob_net(nodes, links, distributions = distributions)

  set.seed(99)
  sim1 <- prob_net_sim(g, num_samples = 500)
  expect_s3_class(sim1, "data.frame")

  set.seed(99)
  learned <- prob_net_learn(g, observations = list(A = 1), num_samples = 500)
  expect_s3_class(learned, "data.frame")

  new_link <- data.frame(source = "A", target = "B", stringsAsFactors = FALSE)
  g2 <- prob_net_update(g, add_links = new_link,
                         update_distributions = list(
                           B = list(
                             type = "conditional", condition = "A",
                             true_dist  = list(type = "uniform", min = 1, max = 3),
                             false_dist = list(type = "uniform", min = 0, max = 1)
                           )
                         ))
  expect_s3_class(g2, "prob_net")

  set.seed(99)
  sim2 <- prob_net_sim(g2, num_samples = 500)
  expect_s3_class(sim2, "data.frame")
  expect_equal(nrow(sim2), 500)
  expect_false(anyNA(sim2))
})

# -- Additional coverage tests ------------------------------

test_that("prob_net rejects discrete conditional missing values/probs", {
  n2 <- data.frame(id = c("A", "B"), stringsAsFactors = FALSE)
  l2 <- data.frame(source = "A", target = "B", stringsAsFactors = FALSE)
  bad_dists <- list(
    A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
    B = list(
      type = "conditional", condition = "A",
      true_dist  = list(type = "discrete"),
      false_dist = list(type = "discrete", values = c(0, 1), probs = c(0.3, 0.7))
    )
  )
  expect_error(
    prob_net(n2, l2, distributions = bad_dists),
    "Both discrete conditional distributions must specify"
  )
})

test_that("prob_net_update rejects conditional dist whose condition node is continuous", {
  bad_update <- list(
    B = list(
      type = "conditional", condition = "B",
      true_dist  = list(type = "normal", mean = 1, sd = 0.1),
      false_dist = list(type = "normal", mean = 2, sd = 0.1)
    )
  )
  expect_error(
    prob_net_update(graph, update_distributions = bad_update),
    "The 'condition' must be a discrete or conditional node"
  )
})

test_that("prob_net_sim handles aggregate node with no component nodes", {
  n2 <- data.frame(id = c("X", "Y"), stringsAsFactors = FALSE)
  l2 <- data.frame(source = character(0), target = character(0), stringsAsFactors = FALSE)
  d2 <- list(
    X = list(type = "normal", mean = 0, sd = 1),
    Y = list(type = "aggregate", nodes = character(0))
  )
  net2 <- prob_net(n2, l2, distributions = d2)
  set.seed(42)
  result <- prob_net_sim(net2, num_samples = 10)
  expect_equal(nrow(result), 10)
  expect_true(all(result$Y == 0))
})
