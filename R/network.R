# Internal: derive each node's declared parents from the distribution list.
# A conditional node depends on its `condition`; an aggregate node depends on
# every node it sums. Any other node type declares no parents.
declared_parents <- function(distributions) {
  parents <- list()
  for (node in names(distributions)) {
    dist <- distributions[[node]]
    from <- if (identical(dist$type, "conditional")) {
      as.character(dist$condition)
    } else if (identical(dist$type, "aggregate")) {
      as.character(dist$nodes)
    } else {
      character(0)
    }
    # An aggregate over no components declares no parents.
    if (length(from) > 0) {
      parents[[node]] <- from
    }
  }
  parents
}

# Internal: check that the links and the distributions describe the same DAG.
# The links are load-bearing: the dependency structure declared by the
# distributions must match the edges exactly, so a network whose graph disagrees
# with its distributions is rejected rather than silently simulated. Requiring
# every edge to run forward through `nodes$id` both guarantees acyclicity and
# confirms that the supplied node order is a topological order, which is the
# order [prob_net_sim()] samples in.
validate_prob_net <- function(nodes, links, distributions) {
  node_ids <- as.character(nodes$id)

  if (anyDuplicated(node_ids)) {
    stop("The nodes data frame must not contain duplicate ids.")
  }

  sources <- as.character(links$source)
  targets <- as.character(links$target)
  unknown <- setdiff(c(sources, targets), node_ids)
  if (length(unknown) > 0) {
    stop(paste(
      "Every link source and target must be a node id. Unknown:",
      paste(unique(unknown), collapse = ", ")
    ))
  }

  if (any(sources == targets)) {
    stop("The links data frame must not contain self-loops.")
  }

  link_edges <- paste(sources, targets, sep = " -> ")

  if (!is.null(distributions)) {
    extra <- setdiff(names(distributions), node_ids)
    if (length(extra) > 0) {
      stop(paste(
        "Distributions must be named for nodes in the network. Unknown:",
        paste(extra, collapse = ", ")
      ))
    }

    parents <- declared_parents(distributions)
    parent_ids <- unique(unlist(parents))
    missing_parents <- setdiff(parent_ids, node_ids)
    if (length(missing_parents) > 0) {
      stop(paste(
        "Every node a distribution depends on must be a node in the network.",
        "Unknown:", paste(missing_parents, collapse = ", ")
      ))
    }

    declared_edges <- character(0)
    for (node in names(parents)) {
      declared_edges <- c(declared_edges, paste(parents[[node]], node, sep = " -> "))
    }
    declared_edges <- unique(declared_edges)

    undeclared <- setdiff(unique(link_edges), declared_edges)
    if (length(undeclared) > 0) {
      stop(paste(
        "Every link must correspond to a dependency declared by the",
        "distributions. Links with no matching dependency:",
        paste(undeclared, collapse = "; ")
      ))
    }

    unlinked <- setdiff(declared_edges, unique(link_edges))
    if (length(unlinked) > 0) {
      stop(paste(
        "Every dependency declared by the distributions must appear in the",
        "links. Dependencies with no matching link:",
        paste(unlinked, collapse = "; ")
      ))
    }
  }

  position <- stats::setNames(seq_along(node_ids), node_ids)
  backward <- position[sources] >= position[targets]
  if (any(backward)) {
    stop(paste(
      "The nodes must be supplied in a topological order, with every link",
      "running from an earlier node to a later one; a graph containing a cycle",
      "can never satisfy this. Offending links:",
      paste(link_edges[backward], collapse = "; ")
    ))
  }

  invisible(TRUE)
}

#' Probabilistic Network of Project Risks.
#'
#' This function is part of the probabilistic network module, whose API may
#' still evolve in future versions.
#'
#' This function creates a probabilistic network graph representation of project risks
#' that supports discrete and continuous probability distributions.
#'
#' @param nodes A data frame containing the nodes of the graph. Must include a column `id`
#'   with unique identifiers for each node.
#' @param links A data frame containing the links of the graph. Must include columns `source`
#'   and `target` specifying the nodes that form each edge.
#' @param distributions A named list where names correspond to node IDs and values specify
#'   discrete probabilities, continuous probability distributions, conditional distributions, or aggregate distributions.
#'   - "discrete": Specifies `values` and `probs`.
#'   - "normal": Specifies `mean` and `sd`.
#'   - "lognormal": Specifies `meanlog` and `sdlog`.
#'   - "uniform": Specifies `min` and `max`.
#'   - "conditional": Specifies a `condition` (a discrete or conditional node) and two distributions (`true_dist`, `false_dist`).
#'     The conditional distributions can themselves be discrete or continuous.
#'   - "aggregate": Specifies `nodes` (a list of continuous node IDs to sum).
#'
#' @details
#' The links are load-bearing. A conditional node depends on its `condition` and
#' an aggregate node depends on every node it sums, and `prob_net()` requires the
#' edges in `links` to match that declared structure exactly: an edge with no
#' corresponding dependency, or a dependency with no corresponding edge, is an
#' error rather than a silently ignored inconsistency. Nodes must additionally be
#' supplied in a topological order, with every link running from an earlier node
#' to a later one, which is the order [prob_net_sim()] samples in and which also
#' guarantees the graph is acyclic.
#'
#' @return An S3 object of class `"prob_net"`: a list with
#' - `nodes`: The input `nodes` data frame.
#' - `links`: The input `links` data frame.
#' - `adjacency_matrix`: A directed matrix with a 1 in `[source, target]` for
#'   every edge.
#' - `distributions`: The input `distributions` list.
#'
#' Objects of this class have [print.prob_net()], [summary.prob_net()] and
#' [plot.prob_net()] methods.
#'
#' @examples
#' nodes <- data.frame(id = c("A", "B", "C", "D"))
#' links <- data.frame(
#'   source = c("A", "B", "C"),
#'   target = c("B", "D", "D")
#' )
#' distributions <- list(
#'   A = list(type = "discrete", values = c(1, 0), probs = c(0.5, 0.5)),
#'   B = list(
#'     type = "conditional", condition = "A",
#'     true_dist  = list(type = "normal", mean = 1, sd = 0.5),
#'     false_dist = list(type = "lognormal", meanlog = -1, sdlog = 0.5)
#'   ),
#'   C = list(type = "uniform", min = 1, max = 5),
#'   D = list(type = "aggregate", nodes = c("B", "C"))
#' )
#' graph <- prob_net(nodes, links, distributions = distributions)
#'
#' @export
prob_net <- function(nodes, links, distributions = NULL) {
  # Check inputs
  if (!is.data.frame(nodes) || !is.data.frame(links)) {
    stop("Both nodes and links must be data frames.")
  }

  if (!"id" %in% colnames(nodes)) {
    stop("The nodes data frame must contain a column named 'id'.")
  }

  if (!all(c("source", "target") %in% colnames(links))) {
    stop("The links data frame must contain columns named 'source' and 'target'.")
  }

  if (!is.null(distributions) && !is.list(distributions)) {
    stop("Distributions must be a named list where names correspond to node IDs.")
  }

  if (!is.null(distributions)) {
    for (node in names(distributions)) {
      dist <- distributions[[node]]
      if (!"type" %in% names(dist)) {
        stop("Each distribution must specify a 'type'.")
      }
      if (dist$type == "discrete") {
        if (!all(c("values", "probs") %in% names(dist))) {
          stop("Discrete distributions must have 'values' and 'probs' specified.")
        }
        if (length(dist$values) != length(dist$probs)) {
          stop("'values' and 'probs' must have the same length.")
        }
        if (abs(sum(dist$probs) - 1) > 1e-6) {
          stop("Probabilities in discrete distributions must sum to 1.")
        }
      } else if (dist$type == "conditional") {
        if (!all(c("condition", "true_dist", "false_dist") %in% names(dist))) {
          stop("Conditional distributions must specify 'condition', 'true_dist', and 'false_dist'.")
        }
        if (!dist$condition %in% names(distributions) ||
            !distributions[[dist$condition]]$type %in% c("discrete", "conditional")) {
          stop("The 'condition' must be a discrete or conditional node defined in the distributions.")
        }
        if (dist$true_dist$type == "discrete" && dist$false_dist$type == "discrete") {
          # Check discrete conditional structure
          if (!all(c("values", "probs") %in% names(dist$true_dist)) ||
              !all(c("values", "probs") %in% names(dist$false_dist))) {
            stop("Both discrete conditional distributions must specify 'values' and 'probs'.")
          }
        }
      }
    }
  }

  # The graph and the distributions must describe the same DAG, and the node
  # order must be the topological order prob_net_sim() samples in.
  validate_prob_net(nodes, links, distributions)

  # Create a directed adjacency matrix
  node_ids <- nodes$id
  adjacency_matrix <- matrix(0,
                             nrow = length(node_ids), ncol = length(node_ids),
                             dimnames = list(node_ids, node_ids)
  )

  for (i in seq_len(nrow(links))) {
    adjacency_matrix[
      as.character(links$source[i]), as.character(links$target[i])
    ] <- 1
  }

  # Return as a list object
  graph <- list(
    nodes = nodes,
    links = links,
    adjacency_matrix = adjacency_matrix,
    distributions = distributions
  )

  class(graph) <- "prob_net"
  return(graph)
}

#' Perform Inference on a Probabilistic Network of Project Risks.
#'
#' This function is part of the probabilistic network module, whose API may
#' still evolve in future versions.
#'
#' This function performs inference on a probabilistic network of project risks by simulating random samples
#' from the distribution of each node. The function supports normal, uniform, lognormal, discrete, conditional distributions,
#' and aggregate nodes that sum the values of specified continuous nodes.
#'
#' @param network A prob_net object created by `prob_net()`.
#' @param num_samples Number of samples to simulate for each node (default is 1000).
#'
#' @return A data frame with `num_samples` rows and one column per node containing the simulated samples.
#'
#' @details
#' Aggregate nodes are computed as the sum of values from the specified continuous nodes.
#' Conditional nodes depend on a discrete conditional node; if the condition is true (value = 1),
#' the node follows the `true_dist`, otherwise it follows the `false_dist` (value = 0).
#' For discrete distributions, sampling is performed using `sample()`.
#'
#' @examples
#' # Define nodes
#' nodes <- data.frame(
#'   id = c("A", "B", "C", "D"),
#'   label = c("Node A", "Node B", "Node C", "Node D"),
#'   stringsAsFactors = FALSE
#' )
#'
#' # Define links
#' links <- data.frame(
#'   source = c("A", "B", "C"),
#'   target = c("C", "D", "D"),
#'   weight = c(1, 2, 3),
#'   stringsAsFactors = FALSE
#' )
#'
#' # Define distributions for nodes
#' distributions <- list(
#'   A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
#'   B = list(type = "normal", mean = 2, sd = 0.5),
#'   C = list(
#'     type = "conditional", condition = "A",
#'     true_dist = list(type = "normal", mean = 1, sd = 0.5),
#'     false_dist = list(type = "lognormal", meanlog = 0, sdlog = 0.2)
#'   ),
#'   D = list(type = "aggregate", nodes = c("B", "C"))
#' )
#'
#' # Create the network graph
#' graph <- prob_net(nodes, links, distributions = distributions)
#'
#' # Perform inference (simulate 1000 samples)
#' simulation_results <- prob_net_sim(graph, num_samples = 1000)
#' head(simulation_results)
#'
#' @importFrom stats rnorm runif rlnorm sample
#' @export
prob_net_sim <- function(network, num_samples = 1000) {
  if (!inherits(network, "prob_net")) {
    stop("The network must be a prob_net object.")
  }

  nodes <- network$nodes
  distributions <- network$distributions

  samples <- list()

  # Helper function to sample from any supported distribution
  sample_from_dist <- function(dist, n) {
    if (dist$type == "normal") {
      return(rnorm(n, mean = dist$mean, sd = dist$sd))
    } else if (dist$type == "uniform") {
      return(runif(n, min = dist$min, max = dist$max))
    } else if (dist$type == "lognormal") {
      return(rlnorm(n, meanlog = dist$meanlog, sdlog = dist$sdlog))
    } else if (dist$type == "discrete") {
      return(sample(dist$values, size = n, replace = TRUE, prob = dist$probs))
    } else {
      stop(paste("Unsupported distribution type:", dist$type))
    }
  }

  for (node in nodes$id) {
    if (!is.null(distributions) && node %in% names(distributions)) {
      dist <- distributions[[node]]

      if (dist$type == "conditional") {
        # Ensure condition is already sampled
        if (is.null(samples[[dist$condition]])) {
          stop(paste("Conditional dependency on unsampled node:", dist$condition))
        }

        condition_values <- samples[[dist$condition]]
        true_dist <- dist$true_dist
        false_dist <- dist$false_dist

        # Generate samples for both branches
        true_samples <- sample_from_dist(true_dist, num_samples)
        false_samples <- sample_from_dist(false_dist, num_samples)

        # Apply condition (assumes binary condition with value 1 == true)
        samples[[node]] <- ifelse(condition_values == 1, true_samples, false_samples)
      } else if (dist$type == "aggregate") {
        if (length(dist$nodes) == 0) {
          samples[[node]] <- rep(0, num_samples)
        } else {
          component_samples <- sapply(dist$nodes, function(p) samples[[p]])
          samples[[node]] <- rowSums(component_samples)
        }
      } else {
        samples[[node]] <- sample_from_dist(dist, num_samples)
      }
    } else {
      stop(paste("No distribution or probability provided for node", node))
    }
  }
  return(as.data.frame(samples))
}

#' Perform Bayesian Learning on a Probabilistic Network of Project Risks.
#'
#' This function is part of the probabilistic network module, whose API may
#' still evolve in future versions.
#'
#' This function updates a probabilistic network of project risks with observed values for certain nodes
#' and then performs inference to generate posterior distributions for unobserved nodes.
#' The function supports normal, uniform, lognormal, conditional continuous, conditional discrete, discrete,
#' and aggregate (summation) node types.
#'
#' @param network A prob_net object created by `prob_net()`.
#' @param observations A named list where names are node IDs and values are observed values.
#' @param num_samples Number of samples to simulate for each node (default is 1000).
#'
#' @return A data frame with `num_samples` rows and one column per node containing the simulated posterior samples.
#'
#' @details
#' Conditioning is performed by rejection sampling: the network is simulated
#' forward from its priors (as in [prob_net_sim()]) and only the draws whose
#' observed nodes equal the supplied values are retained, repeating until
#' `num_samples` matching draws are collected. Because whole joint draws are
#' filtered, evidence propagates to *upstream* (parent and confounding) nodes as
#' well as downstream ones. This distinguishes observational conditioning
#' ("seeing", the sense of \[Pearl 2009\]) from intervention ("doing"): only
#' when the observed node is a root cause with no shared ancestry do
#' `prob_net_learn()` and [prob_net_update()] induce the same distribution.
#'
#' Because matches are exact, observations are supported on discrete (or
#' discrete-conditional) nodes; observing a continuous node has probability zero
#' of an exact match and will raise an error. Nodes not listed in
#' `observations` retain their model distributions. If `observations` is empty
#' the result is a plain forward simulation.
#'
#' @examples
#' # Define nodes
#' nodes <- data.frame(
#'   id = c("A", "B", "C", "D"),
#'   label = c("Node A", "Node B", "Node C", "Node D"),
#'   stringsAsFactors = FALSE
#' )
#'
#' # Define links
#' links <- data.frame(
#'   source = c("A", "B", "C"),
#'   target = c("C", "D", "D"),
#'   weight = c(1, 2, 3),
#'   stringsAsFactors = FALSE
#' )
#'
#' # Define distributions for nodes
#' distributions <- list(
#'   A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
#'   B = list(type = "normal", mean = 2, sd = 0.5),
#'   C = list(
#'     type = "conditional", condition = "A",
#'     true_dist = list(type = "normal", mean = 1, sd = 0.5),
#'     false_dist = list(type = "discrete", values = c(0, 1), probs = c(0.4, 0.6))
#'   ),
#'   D = list(type = "aggregate", nodes = c("B", "C"))
#' )
#'
#' # Create the network graph
#' graph <- prob_net(nodes, links, distributions = distributions)
#'
#' # Perform Bayesian updating with observations
#' observations <- list(A = 1)
#' updated_results <- prob_net_learn(graph, observations, num_samples = 1000)
#' head(updated_results)
#'
#' @importFrom stats rnorm runif rlnorm sample
#' @export
prob_net_learn <- function(network, observations = list(), num_samples = 1000) {
  if (!inherits(network, "prob_net")) {
    stop("The network must be a prob_net object.")
  }

  nodes <- network$nodes
  distributions <- network$distributions

  # Every node must be either observed or have a model distribution.
  for (node in nodes$id) {
    if (!(node %in% names(observations)) &&
        (is.null(distributions) || !(node %in% names(distributions)))) {
      stop(paste("No distribution or observation provided for node", node))
    }
  }

  # With no observations, conditioning reduces to plain forward simulation.
  if (length(observations) == 0) {
    return(prob_net_sim(network, num_samples = num_samples))
  }

  # Observational conditioning via rejection sampling. Drawing whole joint
  # samples from the prior and retaining those consistent with the observed
  # values propagates evidence to upstream (parent and confounding) nodes,
  # unlike clamping a node and forward-sampling, which leaves ancestors at their
  # priors. This is what makes "seeing" differ from "doing" under confounding.
  accepted <- NULL
  batch <- max(as.integer(num_samples) * 2L, 1000L)
  max_iter <- 200L

  for (iter in seq_len(max_iter)) {
    sim <- prob_net_sim(network, num_samples = batch)
    keep <- rep(TRUE, nrow(sim))
    for (obs_node in names(observations)) {
      keep <- keep & (sim[[obs_node]] == observations[[obs_node]])
    }
    matched <- sim[keep, , drop = FALSE]
    if (nrow(matched) > 0L) {
      accepted <- if (is.null(accepted)) matched else rbind(accepted, matched)
    }
    if (!is.null(accepted) && nrow(accepted) >= num_samples) break
  }

  if (is.null(accepted) || nrow(accepted) < num_samples) {
    stop(paste0(
      "Observational conditioning could not collect ", num_samples,
      " samples matching the observations. The observed event may be too rare, ",
      "or an observed node may be continuous (exact matches have probability ",
      "zero). For interventions on continuous nodes use prob_net_update()."
    ))
  }

  accepted <- accepted[seq_len(num_samples), , drop = FALSE]
  rownames(accepted) <- NULL
  return(accepted)
}

#' Update a Probabilistic Network of Project Risks.
#'
#' This function is part of the probabilistic network module, whose API may
#' still evolve in future versions.
#'
#' This function updates an existing probabilistic network by adding or removing dependencies (edges)
#' and updating probability distributions for nodes.
#'
#' @param graph An existing probabilistic network created by `prob_net()`.
#' @param add_links Optional. A data frame with columns `source` and `target` to add new links.
#' @param remove_links Optional. A data frame with columns `source` and `target` to remove existing links.
#' @param update_distributions Optional. A named list of distributions to update. Format follows `prob_net()`.
#'
#' @details
#' The updated network is re-validated with the same rules `prob_net()` applies,
#' so the edge changes and the distribution changes must agree. Removing the edge
#' into a conditional node without also replacing that node's distribution is an
#' error, which is what makes `remove_links` structurally meaningful: an
#' intervention that severs a dependency has to sever it in both the graph and
#' the distribution list.
#'
#' @examples
#' nodes <- data.frame(id = c("A", "B", "C"))
#' links <- data.frame(source = c("A", "B"), target = c("B", "C"))
#' distributions <- list(
#'   A = list(type = "discrete", values = c(1, 0), probs = c(0.5, 0.5)),
#'   B = list(
#'     type = "conditional", condition = "A",
#'     true_dist  = list(type = "normal", mean = 5, sd = 1),
#'     false_dist = list(type = "normal", mean = 1, sd = 1)
#'   ),
#'   C = list(type = "aggregate", nodes = "B")
#' )
#' graph <- prob_net(nodes, links, distributions)
#'
#' # Intervene on B: sever its dependence on A and fix it to the baseline cost.
#' updated_graph <- prob_net_update(
#'   graph,
#'   remove_links = data.frame(source = "A", target = "B"),
#'   update_distributions = list(B = list(type = "normal", mean = 1, sd = 1))
#' )
#'
#' @return An updated `prob_net` object with modified links and/or distributions.
#'
#' @export
prob_net_update <- function(graph, add_links = NULL, remove_links = NULL, update_distributions = NULL) {
  if (!inherits(graph, "prob_net")) {
    stop("The graph must be a prob_net object.")
  }

  nodes <- graph$nodes
  links <- graph$links
  distributions <- graph$distributions

  # Add new links
  if (!is.null(add_links)) {
    if (!all(c("source", "target") %in% colnames(add_links))) {
      stop("add_links must have 'source' and 'target' columns.")
    }
    links <- rbind(links, add_links)
  }

  # Remove specified links
  if (!is.null(remove_links)) {
    if (!all(c("source", "target") %in% colnames(remove_links))) {
      stop("remove_links must have 'source' and 'target' columns.")
    }
    for (i in seq_len(nrow(remove_links))) {
      links <- links[!(links$source == remove_links$source[i] & links$target == remove_links$target[i]), ]
    }
  }

  # Update distributions
  if (!is.null(update_distributions)) {
    if (!is.list(update_distributions)) {
      stop("update_distributions must be a named list.")
    }

    for (node in names(update_distributions)) {
      if (!node %in% nodes$id) {
        stop(paste("Node", node, "not found in the network nodes."))
      }
      dist <- update_distributions[[node]]
      if (!"type" %in% names(dist)) {
        stop("Each distribution must specify a 'type'.")
      }

      if (dist$type == "discrete") {
        if (!all(c("values", "probs") %in% names(dist))) {
          stop("Discrete distributions must have 'values' and 'probs' specified.")
        }
        if (length(dist$values) != length(dist$probs)) {
          stop("'values' and 'probs' must have the same length.")
        }
        if (abs(sum(dist$probs) - 1) > 1e-6) {
          stop("Probabilities in discrete distributions must sum to 1.")
        }
      } else if (dist$type == "conditional") {
        if (!all(c("condition", "true_dist", "false_dist") %in% names(dist))) {
          stop("Conditional distributions must specify 'condition', 'true_dist', and 'false_dist'.")
        }
        if (!dist$condition %in% names(distributions) ||
            !distributions[[dist$condition]]$type %in% c("discrete", "conditional")) {
          stop("The 'condition' must be a discrete or conditional node defined in the distributions.")
        }
      }
      # Update or insert distribution
      distributions[[node]] <- dist
    }
  }

  # The edge changes and the distribution changes must leave the network
  # consistent, so an intervention has to sever a dependency in both.
  validate_prob_net(nodes, links, distributions)

  # Recreate the directed adjacency matrix
  node_ids <- nodes$id
  adjacency_matrix <- matrix(0,
                             nrow = length(node_ids), ncol = length(node_ids),
                             dimnames = list(node_ids, node_ids)
  )

  for (i in seq_len(nrow(links))) {
    adjacency_matrix[
      as.character(links$source[i]), as.character(links$target[i])
    ] <- 1
  }

  updated_graph <- list(
    nodes = nodes,
    links = links,
    adjacency_matrix = adjacency_matrix,
    distributions = distributions
  )

  class(updated_graph) <- "prob_net"
  return(updated_graph)
}


# Internal: assign each node its longest-path layer. The node order is a
# topological order (guaranteed by validate_prob_net), so one forward pass is
# enough and no cycle detection is needed.
prob_net_layers <- function(x) {
  a <- x$adjacency_matrix
  n <- nrow(a)
  layer <- integer(n)
  if (n == 0) return(stats::setNames(layer, character(0)))
  for (i in seq_len(n)) {
    parents <- which(a[, i] == 1)
    layer[i] <- if (length(parents) == 0) 0L else max(layer[parents]) + 1L
  }
  stats::setNames(layer, rownames(a))
}


# Internal: render a node's distribution spec as a short readable string.
format_node_dist <- function(dist, width = 40) {
  if (is.null(dist)) return(NA_character_)
  txt <- switch(dist$type,
    normal = paste0("normal(mean = ", dist$mean, ", sd = ", dist$sd, ")"),
    lognormal = paste0("lognormal(meanlog = ", dist$meanlog,
                       ", sdlog = ", dist$sdlog, ")"),
    uniform = paste0("uniform(", dist$min, ", ", dist$max, ")"),
    discrete = paste0("discrete{",
                      paste(dist$values, dist$probs, sep = ":", collapse = ", "),
                      "}"),
    conditional = paste0("if ", dist$condition,
                         " then ", format_node_dist(dist$true_dist, width = Inf),
                         " else ", format_node_dist(dist$false_dist, width = Inf)),
    aggregate = paste0("sum(", paste(dist$nodes, collapse = ", "), ")"),
    dist$type
  )
  if (is.finite(width) && nchar(txt) > width) {
    txt <- paste0(substr(txt, 1, width - 3), "...")
  }
  txt
}


#' Print a probabilistic network.
#'
#' Displays the size and shape of the network: node and edge counts, how many
#' nodes are roots or terminal, the depth of the causal chain, and which
#' distribution types are in use.
#'
#' @param x An object of class `"prob_net"` returned by [prob_net()] or
#'   [prob_net_update()].
#' @param ... Additional arguments (not used).
#' @return Invisibly returns `x`.
#' @srrstats {G1.4} *Documented with roxygen2.*
#' @examples
#' nodes <- data.frame(id = c("Risk", "Task"), stringsAsFactors = FALSE)
#' links <- data.frame(source = "Risk", target = "Task", stringsAsFactors = FALSE)
#' dists <- list(
#'   Risk = list(type = "discrete", values = c(0, 1), probs = c(0.7, 0.3)),
#'   Task = list(
#'     type = "conditional", condition = "Risk",
#'     true_dist = list(type = "normal", mean = 20, sd = 4),
#'     false_dist = list(type = "normal", mean = 10, sd = 2)
#'   )
#' )
#' net <- prob_net(nodes, links, distributions = dists)
#' print(net)
#' @export
#' @method print prob_net
print.prob_net <- function(x, ...) {
  a <- x$adjacency_matrix
  n <- nrow(a)
  cat("Probabilistic Network of Project Risks\n")

  if (n == 0) {
    cat("Nodes: 0   Edges: 0\n")
    cat("The network is empty.\n")
    return(invisible(x))
  }

  layers <- prob_net_layers(x)
  cat("Nodes:", n,
      "  Edges:", sum(a),
      "  Roots:", sum(colSums(a) == 0),
      "  Terminal:", sum(rowSums(a) == 0),
      "  Depth:", max(layers) + 1L, "layers\n")

  if (!is.null(x$distributions)) {
    types <- vapply(x$distributions, function(d) d$type, character(1))
    counts <- table(types)
    cat("Node types: ",
        paste0(names(counts), " (", as.integer(counts), ")", collapse = ", "),
        "\n", sep = "")
    missing <- setdiff(rownames(a), names(x$distributions))
    if (length(missing) > 0) {
      cat("Distributions: missing for ", length(missing), " node(s): ",
          paste(missing, collapse = ", "), "\n", sep = "")
    } else {
      cat("Distributions: complete\n")
    }
  } else {
    cat("Distributions: none declared\n")
  }
  cat("Use summary() for per-node detail and plot() for the network graph.\n")
  invisible(x)
}


#' Summarize a probabilistic network.
#'
#' Builds a per-node table describing the causal structure: each node's layer in
#' the network, its parents, and the distribution it carries.
#'
#' @param object An object of class `"prob_net"`.
#' @param ... Additional arguments (not used).
#' @return An object of class `"summary.prob_net"`, a list with components:
#'   \describe{
#'     \item{n_nodes, n_edges, n_roots, n_terminals, depth}{Structural counts.
#'       `depth` is the number of layers in the longest causal chain.}
#'     \item{type_counts}{A table of distribution types in use, or `NULL`.}
#'     \item{missing_distributions}{Character vector of node ids with no
#'       declared distribution.}
#'     \item{node_table}{Data frame with one row per node, in topological order,
#'       with columns `id`, `label`, `group`, `layer`, `type`, `n_parents`,
#'       `parents` and `parameters`. `label` and `group` are present only when
#'       the nodes data frame carries them.}
#'   }
#' @srrstats {G1.4} *Documented with roxygen2.*
#' @examples
#' nodes <- data.frame(id = c("Risk", "Task"), stringsAsFactors = FALSE)
#' links <- data.frame(source = "Risk", target = "Task", stringsAsFactors = FALSE)
#' dists <- list(
#'   Risk = list(type = "discrete", values = c(0, 1), probs = c(0.7, 0.3)),
#'   Task = list(
#'     type = "conditional", condition = "Risk",
#'     true_dist = list(type = "normal", mean = 20, sd = 4),
#'     false_dist = list(type = "normal", mean = 10, sd = 2)
#'   )
#' )
#' summary(prob_net(nodes, links, distributions = dists))
#' @export
#' @method summary prob_net
summary.prob_net <- function(object, ...) {
  a <- object$adjacency_matrix
  n <- nrow(a)
  ids <- rownames(a)

  if (n == 0) {
    node_table <- data.frame(
      id = character(0), layer = integer(0), type = character(0),
      n_parents = integer(0), parents = character(0),
      parameters = character(0), stringsAsFactors = FALSE
    )
    result <- list(
      n_nodes = 0L, n_edges = 0L, n_roots = 0L, n_terminals = 0L, depth = 0L,
      type_counts = NULL, missing_distributions = character(0),
      node_table = node_table
    )
    class(result) <- "summary.prob_net"
    return(result)
  }

  layers <- prob_net_layers(object)
  parents_of <- lapply(seq_len(n), function(i) ids[which(a[, i] == 1)])

  dists <- object$distributions
  node_table <- data.frame(
    id = ids,
    layer = as.integer(layers) + 1L,
    type = vapply(ids, function(id) {
      d <- if (!is.null(dists)) dists[[id]] else NULL
      if (is.null(d)) NA_character_ else d$type
    }, character(1)),
    n_parents = vapply(parents_of, length, integer(1)),
    parents = vapply(parents_of, function(p) {
      if (length(p) == 0) "" else paste(p, collapse = ", ")
    }, character(1)),
    parameters = vapply(ids, function(id) {
      format_node_dist(if (!is.null(dists)) dists[[id]] else NULL)
    }, character(1)),
    stringsAsFactors = FALSE
  )
  row.names(node_table) <- NULL

  # Carry through the optional descriptive columns when the caller supplied them.
  for (extra in c("label", "group")) {
    if (extra %in% colnames(object$nodes)) {
      node_table[[extra]] <- as.character(
        object$nodes[[extra]][match(ids, as.character(object$nodes$id))]
      )
    }
  }
  ordered_cols <- intersect(
    c("id", "label", "group", "layer", "type", "n_parents", "parents",
      "parameters"),
    colnames(node_table)
  )
  node_table <- node_table[, ordered_cols, drop = FALSE]

  result <- list(
    n_nodes = n,
    n_edges = sum(a),
    n_roots = sum(colSums(a) == 0),
    n_terminals = sum(rowSums(a) == 0),
    depth = max(layers) + 1L,
    type_counts = if (!is.null(dists)) {
      table(vapply(dists, function(d) d$type, character(1)))
    } else {
      NULL
    },
    missing_distributions = if (!is.null(dists)) {
      setdiff(ids, names(dists))
    } else {
      ids
    },
    node_table = node_table
  )
  class(result) <- "summary.prob_net"
  result
}


#' Print a probabilistic network summary.
#'
#' @param x An object of class `"summary.prob_net"` returned by
#'   [summary.prob_net()].
#' @param ... Additional arguments (not used).
#' @return Invisibly returns `x`.
#' @examples
#' nodes <- data.frame(id = c("Risk", "Task"), stringsAsFactors = FALSE)
#' links <- data.frame(source = "Risk", target = "Task", stringsAsFactors = FALSE)
#' dists <- list(
#'   Risk = list(type = "discrete", values = c(0, 1), probs = c(0.7, 0.3)),
#'   Task = list(
#'     type = "conditional", condition = "Risk",
#'     true_dist = list(type = "normal", mean = 20, sd = 4),
#'     false_dist = list(type = "normal", mean = 10, sd = 2)
#'   )
#' )
#' print(summary(prob_net(nodes, links, distributions = dists)))
#' @export
#' @method print summary.prob_net
print.summary.prob_net <- function(x, ...) {
  cat("Probabilistic Network of Project Risks\n")
  cat("------------------------------\n")
  if (x$n_nodes == 0) {
    cat("The network is empty.\n")
    return(invisible(x))
  }
  cat("Nodes:", x$n_nodes, "  Edges:", x$n_edges,
      "  Roots:", x$n_roots, "  Terminal:", x$n_terminals,
      "  Depth:", x$depth, "layers\n")
  if (length(x$missing_distributions) > 0) {
    cat("Missing distributions:",
        paste(x$missing_distributions, collapse = ", "), "\n")
  }
  cat("\nNodes (in topological order):\n")
  print(x$node_table, row.names = FALSE)
  invisible(x)
}


#' Plot a probabilistic network.
#'
#' Draws the network as a layered directed graph: nodes are placed by their
#' longest-path distance from a root, so causes sit above the effects they
#' propagate into. Within-layer ordering is refined by barycenter sweeps to
#' reduce edge crossings.
#'
#' This is a readable layout for the small-to-moderate networks the module is
#' designed for, implemented in base graphics so that no optional dependency is
#' required. It does not route long edges around intervening layers the way a
#' full Sugiyama implementation does. For large or dense graphs, pass the
#' network to a dedicated graph package, for example
#' `igraph::graph_from_data_frame(x$links, vertices = x$nodes)`.
#'
#' @param x An object of class `"prob_net"`.
#' @param main Optional plot title. If `NULL`, a default title is generated.
#' @param col Node fill color or vector of colors. If `NULL`, nodes are colored
#'   by their `group` column when present, and uniformly otherwise.
#' @param vertical Logical. If `TRUE` (default), layers run top to bottom;
#'   otherwise left to right.
#' @param node_cex Node symbol size, passed to [graphics::points()].
#' @param label_cex Node label size, passed to [graphics::text()].
#' @param ... Additional arguments passed to [graphics::plot()].
#' @return Invisibly returns `x`.
#' @importFrom graphics arrows text points legend
#' @importFrom grDevices colorRampPalette
#' @srrstats {G1.4} *Documented with roxygen2.*
#' @examples
#' nodes <- data.frame(id = c("Risk", "Task"), stringsAsFactors = FALSE)
#' links <- data.frame(source = "Risk", target = "Task", stringsAsFactors = FALSE)
#' dists <- list(
#'   Risk = list(type = "discrete", values = c(0, 1), probs = c(0.7, 0.3)),
#'   Task = list(
#'     type = "conditional", condition = "Risk",
#'     true_dist = list(type = "normal", mean = 20, sd = 4),
#'     false_dist = list(type = "normal", mean = 10, sd = 2)
#'   )
#' )
#' plot(prob_net(nodes, links, distributions = dists))
#' @export
#' @method plot prob_net
plot.prob_net <- function(x, main = NULL, col = NULL, vertical = TRUE,
                          node_cex = 3, label_cex = 0.7, ...) {
  a <- x$adjacency_matrix
  n <- nrow(a)
  if (n == 0) {
    message("Nothing to plot: the network has no nodes.")
    return(invisible(x))
  }
  if (is.null(main)) main <- "Probabilistic Network of Project Risks"

  layer <- prob_net_layers(x)
  ids <- rownames(a)

  # Within-layer ordering: start from topological order, then alternate
  # downward and upward barycenter sweeps to reduce edge crossings.
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
        neighbours <- if (sweep == 1) which(a[, i] == 1) else which(a[i, ] == 1)
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

  # Node colors: by group when available, otherwise the package fill.
  pal <- pra_cols()
  groups <- NULL
  if (is.null(col)) {
    if ("group" %in% colnames(x$nodes)) {
      groups <- factor(
        as.character(x$nodes$group[match(ids, as.character(x$nodes$id))])
      )
      ramp <- grDevices::colorRampPalette(
        c("#18bc9c", "#3498db", "#e74c3c", "#2c3e50")
      )(nlevels(groups))
      fill <- ramp[as.integer(groups)]
    } else {
      fill <- rep(unname(pal["fill"]), n)
    }
  } else {
    fill <- rep(col, length.out = n)
  }

  graphics::plot(xs, ys,
    type = "n", axes = FALSE, xlab = "", ylab = "", main = main,
    xlim = range(xs) + c(-1, 1), ylim = range(ys) + c(-1, 1), ...
  )

  # Edges, shortened at both ends so arrowheads land on the node boundary.
  edges <- which(a == 1, arr.ind = TRUE)
  if (nrow(edges) > 0) {
    radius <- 0.18
    for (k in seq_len(nrow(edges))) {
      i <- edges[k, 1]
      j <- edges[k, 2]
      dx <- xs[j] - xs[i]
      dy <- ys[j] - ys[i]
      len <- sqrt(dx^2 + dy^2)
      if (len == 0) next
      ux <- dx / len
      uy <- dy / len
      graphics::arrows(
        xs[i] + ux * radius, ys[i] + uy * radius,
        xs[j] - ux * radius, ys[j] - uy * radius,
        length = 0.08, col = unname(pal["ink"])
      )
    }
  }

  graphics::points(xs, ys,
    pch = 21, bg = fill, col = unname(pal["ink"]), cex = node_cex
  )

  labels <- ids
  if ("label" %in% colnames(x$nodes)) {
    labels <- as.character(x$nodes$label[match(ids, as.character(x$nodes$id))])
  }
  graphics::text(xs, ys - 0.4, labels = labels, cex = label_cex)

  if (!is.null(groups) && nlevels(groups) > 1) {
    ramp <- grDevices::colorRampPalette(
      c("#18bc9c", "#3498db", "#e74c3c", "#2c3e50")
    )(nlevels(groups))
    graphics::legend("topright",
      legend = levels(groups), pt.bg = ramp, pch = 21,
      col = unname(pal["ink"]), cex = 0.8, bg = "white"
    )
  }
  invisible(x)
}
