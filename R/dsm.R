#' Resource-based 'Parent' Design Structure Matrix (DSM).
#'
#' @param S Resource-Task Matrix 'S' giving the links (arcs) between resources and tasks.
#' @return The function returns the Resource-based 'Parent' DSM 'P' giving the number
#' of resources shared between each task.
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
#' @export

# Parent DSM function
parent_dsm <- function(S) {
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
#' @param S Resource-Task Matrix 'S' giving the links (arcs) between resources and tasks.
#' @param R Risk-Resource Matrix 'R' giving the links (arcs) between risks and resources.
#' @return The function returns the Risk-based 'Grandparent' DSM 'G' giving the number
#' of risks shared between each task.
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
#' @export

# Grandparent DSM function
grandparent_dsm <- function(S, R) {
  # Check if matrix S is square
  if (ncol(S) != nrow(S)) {
    stop("Matrix S must be square.")
  }

  # Check if the matrices can be multiplied
  if (ncol(S) != ncol(R)) {
    stop("Number of columns in the Matrix S must be equal to the number
         of columns in Matrix R.")
  }

  # Multiply matrix S by the transpose of R
  t <- S %*% t(R)

  # Multiply matrix T by the transpose of T
  grandparent_dsm <- t %*% t(t)

  return(grandparent_dsm)
}
