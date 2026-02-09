#' Resource-based 'Parent' Design Structure Matrix (DSM).
#'
#' This function computes the Resource-based 'Parent' Design Structure Matrix (DSM)
#' from a given Resource-Task Matrix 'S'. The 'Parent' DSM indicates the number of resources
#' shared between each pair of tasks in a project.
#'
#' @srrstats {G1.0} *Software lists primary reference from published academic literature.*
#' @srrstats {G1.1} *Software is the first implementation within **R** of the algorithm which has previously been implemented in other languages or contexts.*
#' @srrstats {G1.4} *Software uses [`roxygen2`](https://roxygen2.r-lib.org/) to document all functions.*
#' @srrstats {G2.0} *Implements assertions on dimensions of matrix input - validates square matrix.*
#' @srrstats {G2.0a} *Parameter documentation explicitly states expected input structure (square matrix).*
#' @srrstats {G2.1} *Implements assertions on types of inputs via is.matrix(), is.data.frame(), and is.numeric() checks.*
#' @srrstats {G2.1a} *Parameter documentation explicitly states data types expected (matrix or data frame).*
#' @srrstats {G2.7} *Accepts both matrix and data.frame as input.*
#' @srrstats {G2.15} *Implements checks for NaN values via is.nan() prior to processing.*
#' @srrstats {G2.16} *Implements checks for Inf/-Inf values via is.infinite() prior to processing.*
#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*
#'
#' @param S Resource-Task Matrix 'S' giving the links (arcs) between resources and tasks.
#' @return The function returns the Resource-based 'Parent' DSM 'P' giving the number
#' of resources shared between each task.
#' @references
#' Govan, Paul, and Ivan Damnjanovic. "The resource-based view on project risk management."
#' Journal of construction engineering and management 142.9 (2016): 04016034.
#' @examples
#' # Set the S matrix for a toy project and print the results.
#' s <- matrix(c(1, 1, 0, 0, 1, 0, 0, 1, 1), nrow = 3, ncol = 3)
#' cat("Resource-Task Matrix:\n")
#' print(s)
#'
#' # Calculate the Resource-based Parent DSM and print the results.
#' resource_dsm <- parent_dsm(s)
#' cat("\nResource-based 'Parent' DSM:\n")
#' print(resource_dsm)
#'
#' @export
# Parent DSM function
parent_dsm <- function(S) {
  # Error handling
  if (is.null(S)) {
    stop("S must not be NULL")
  }
  if (!is.matrix(S) && !is.data.frame(S)) {
    stop("S must be a matrix or data frame")
  }
  if (!is.numeric(as.matrix(S))) {
    stop("S must contain numeric values")
  }
  if (any(is.nan(as.matrix(S)))) {
    stop("S must not contain NaN values")
  }
  if (anyNA(as.matrix(S))) {
    stop("S must not contain NA values")
  }
  if (any(is.infinite(as.matrix(S)))) {
    stop("S must not contain infinite values")
  }
  # Check if the matrix is square
  if (ncol(S) != nrow(S)) {
    stop("The Resource-Task Matrix must be square.")
  }

  # Multiply matrix S by the transpose of R
  parent_dsm <- S %*% t(S)

  return(parent_dsm)
}


#' Risk-based 'Grandparent' Design Structure Matrix (DSM).
#'
#' This function computes the Risk-based 'Grandparent' Design Structure Matrix (DSM)
#' from given Resource-Task Matrix 'S' and Risk-Resource Matrix 'R'.
#' The 'Grandparent' DSM indicates the number of risks shared between each pair of
#' tasks in a project.
#'
#' @srrstats {G1.0} *Software lists primary reference from published academic literature.*
#' @srrstats {G1.1} *Software is the first implementation within **R** of the algorithm which has previously been implemented in other languages or contexts.*
#' @srrstats {G1.4} *Software uses [`roxygen2`](https://roxygen2.r-lib.org/) to document all functions.*
#' @srrstats {G2.0} *Implements assertions on dimensions of matrix inputs - validates square matrix S and compatible dimensions.*
#' @srrstats {G2.0a} *Parameter documentation explicitly states expected input structure (square matrix S, compatible R).*
#' @srrstats {G2.1} *Implements assertions on types of inputs via is.matrix(), is.data.frame(), and is.numeric() checks.*
#' @srrstats {G2.1a} *Parameter documentation explicitly states data types expected (matrix or data frame).*
#' @srrstats {G2.7} *Accepts both matrix and data.frame as input.*
#' @srrstats {G2.15} *Implements checks for NaN values via is.nan() prior to processing.*
#' @srrstats {G2.16} *Implements checks for Inf/-Inf values via is.infinite() prior to processing.*
#' @srrstats {G5.2a} *Each error message produced by stop() is unique.*
#'
#' @param S Resource-Task Matrix 'S' giving the links (arcs) between resources and tasks.
#' @param R Risk-Resource Matrix 'R' giving the links (arcs) between risks and resources.
#' @return The function returns the Risk-based 'Grandparent' DSM 'G' giving the number
#' of risks shared between each task.
#' @references
#' Govan, Paul, and Ivan Damnjanovic. "The resource-based view on project risk management."
#' Journal of construction engineering and management 142.9 (2016): 04016034.
#' @examples
#' # Set the S and R matrices and print the results.
#' S <- matrix(c(1, 1, 0, 0, 1, 0, 0, 1, 1), nrow = 3, ncol = 3)
#' R <- matrix(c(1, 1, 1, 1, 0, 0), nrow = 2, ncol = 3)
#' cat("Resource-Task Matrix:\n")
#' print(S)
#' cat("\nRisk-Resource Matrix:\n")
#' print(R)
#' # Calculate the Risk-based Grandparent Matrix and print the results.
#' risk_dsm <- grandparent_dsm(S, R)
#' cat("\nRisk-based 'Grandparent' DSM:\n")
#' print(risk_dsm)
#'
#' @export

# Grandparent DSM function
grandparent_dsm <- function(S, R) {
  # Error handling
  if (is.null(S) || is.null(R)) {
    stop("S and R must not be NULL")
  }
  if (!is.matrix(S) && !is.data.frame(S)) {
    stop("S must be a matrix or data frame")
  }
  if (!is.matrix(R) && !is.data.frame(R)) {
    stop("R must be a matrix or data frame")
  }
  if (!is.numeric(as.matrix(S)) || !is.numeric(as.matrix(R))) {
    stop("S and R must contain numeric values")
  }
  if (any(is.nan(as.matrix(S))) || any(is.nan(as.matrix(R)))) {
    stop("S and R must not contain NaN values")
  }
  if (anyNA(as.matrix(S)) || anyNA(as.matrix(R))) {
    stop("S and R must not contain NA values")
  }
  if (any(is.infinite(as.matrix(S))) || any(is.infinite(as.matrix(R)))) {
    stop("S and R must not contain infinite values")
  }
  # Check if matrix S is square
  if (ncol(S) != nrow(S)) {
    stop("Matrix S must be square.")
  }

  # Check if the matrices can be multiplied
  if (ncol(S) != ncol(R)) {
    stop("Number of columns in the Matrix S must be equal to the number of columns in Matrix R.")
  }

  # Multiply matrix S by the transpose of R
  t <- S %*% t(R)

  # Multiply matrix T by the transpose of T
  grandparent_dsm <- t %*% t(t)

  return(grandparent_dsm)
}
