#' Probabilistic Network of Project Risks.
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
#'   - "conditional": Specifies a `condition` (a discrete node) and two distributions (`true_dist`, `false_dist`).
#'     The conditional distributions can themselves be discrete or continuous.
#'   - "aggregate": Specifies `nodes` (a list of continuous node IDs to sum).
#'
#' @return A list with:
#' - `nodes`: The input `nodes` data frame.
#' - `links`: The input `links` data frame.
#' - `adjacency_matrix`: A matrix representing connections between nodes.
#' - `distributions`: The input `distributions` list.
#'
#' @examples
#' nodes <- data.frame(id = c("A", "B", "C", "D"))
#' links <- data.frame(source = c("A", "B", "C"), target = c("B", "C", "D"))
#' distributions <- list(
#'   A = list(type = "discrete", values = c(0, 1), probs = c(0.5, 0.5)),
#'   B = list(type = "normal", mean = 0, sd = 1),
#'   C = list(type = "lognormal", meanlog = 0, sdlog = 0.5),
#'   D = list(type = "uniform", min = 1, max = 5),
#'   E = list(
#'     type = "conditional", condition = "A",
#'     true_dist = list(type = "normal", mean = 1, sd = 0.5),
#'     false_dist = list(type = "lognormal", meanlog = -1, sdlog = 0.5)
#'   )
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
        if (!dist$condition %in% names(distributions) || distributions[[dist$condition]]$type != "discrete") {
          stop("The 'condition' must be a discrete node defined in the distributions.")
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

  # Create an adjacency matrix
  node_ids <- nodes$id
  adjacency_matrix <- matrix(0,
    nrow = length(node_ids), ncol = length(node_ids),
    dimnames = list(node_ids, node_ids)
  )

  for (i in seq_len(nrow(links))) {
    source <- links$source[i]
    target <- links$target[i]

    adjacency_matrix[source, target] <- adjacency_matrix[source, target] + 1
    adjacency_matrix[target, source] <- adjacency_matrix[target, source] + 1
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
#'   source = c("A", "A", "B", "C"),
#'   target = c("B", "C", "D", "D"),
#'   weight = c(1, 2, 3, 4),
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
        component_samples <- sapply(dist$nodes, function(p) samples[[p]])
        samples[[node]] <- rowSums(component_samples)
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
#' Normal nodes are sampled from a normal distribution using the specified mean and sd.
#' Uniform nodes are sampled from a uniform distribution between the specified min and max values.
#' Lognormal nodes are sampled from a lognormal distribution with specified meanlog and sdlog.
#' Conditional nodes depend on a discrete conditional node; if the condition is TRUE (value = 1), the node follows
#' the `true_dist`, otherwise it follows the `false_dist` (value = 0). Conditional distributions can be normal, lognormal, uniform, or discrete.
#' Discrete nodes are sampled using `sample()`, and aggregate nodes are computed as the sum of values from the specified nodes.
#' Observed nodes are fixed at their given values.
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
#'   source = c("A", "A", "B", "C"),
#'   target = c("B", "C", "D", "D"),
#'   weight = c(1, 2, 3, 4),
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
    if (node %in% names(observations)) {
      # Use observed value replicated across samples
      samples[[node]] <- rep(observations[[node]], num_samples)
    } else if (!is.null(distributions) && node %in% names(distributions)) {
      dist <- distributions[[node]]

      if (dist$type == "conditional") {
        if (is.null(samples[[dist$condition]])) {
          stop(paste("Conditional dependency on unsampled or unobserved node:", dist$condition))
        }

        condition_values <- samples[[dist$condition]]
        true_dist <- dist$true_dist
        false_dist <- dist$false_dist

        # Sample both true and false branches
        true_samples <- sample_from_dist(true_dist, num_samples)
        false_samples <- sample_from_dist(false_dist, num_samples)

        # Apply condition (assumes binary condition where 1 = TRUE)
        samples[[node]] <- ifelse(condition_values == 1, true_samples, false_samples)
      } else if (dist$type == "aggregate") {
        component_samples <- sapply(dist$nodes, function(p) samples[[p]])
        samples[[node]] <- rowSums(component_samples)
      } else {
        samples[[node]] <- sample_from_dist(dist, num_samples)
      }
    } else {
      stop(paste("No distribution or observation provided for node", node))
    }
  }

  return(as.data.frame(samples))
}

#' Update a Probabilistic Network of Project Risks.
#'
#' This function updates an existing probabilistic network by adding or removing dependencies (edges)
#' and updating probability distributions for nodes.
#'
#' @param graph An existing probabilistic network created by `prob_net()`.
#' @param add_links Optional. A data frame with columns `source` and `target` to add new links.
#' @param remove_links Optional. A data frame with columns `source` and `target` to remove existing links.
#' @param update_distributions Optional. A named list of distributions to update. Format follows `prob_net()`.
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
        if (!dist$condition %in% names(distributions) || distributions[[dist$condition]]$type != "discrete") {
          stop("The 'condition' must be a discrete node defined in the distributions.")
        }
      }
      # Update or insert distribution
      distributions[[node]] <- dist
    }
  }

  # Recreate adjacency matrix
  node_ids <- nodes$id
  adjacency_matrix <- matrix(0,
    nrow = length(node_ids), ncol = length(node_ids),
    dimnames = list(node_ids, node_ids)
  )

  for (i in seq_len(nrow(links))) {
    source <- links$source[i]
    target <- links$target[i]

    adjacency_matrix[source, target] <- adjacency_matrix[source, target] + 1
    adjacency_matrix[target, source] <- adjacency_matrix[target, source] + 1
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
