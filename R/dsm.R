#' Resource-based 'Parent' Design Structure Matrix (DSM).
#'
#' @param sm Resource-Task Matrix 'S' giving the links (arcs) between resources and tasks.
#' @return The function returns the Resource-based 'Parent' DSM 'P' giving the number
#' of resources shared between each task.
#' @examples
#' sm <- matrix(c(1, 1, 0, 0, 1, 0, 0, 1, 1), nrow = 3, ncol = 3)
#' cat("Resource-Task Matrix:\n")
#' print(sm)
#' resource_dsm <- parent_dsm(sm)
#' cat("\nResource-based 'Parent' DSM:\n")
#' print(resource_dsm)
#' @seealso \url{https://ascelibrary.org/doi/abs/10.1061/AJRUA6.0001041}
#' @export

# Parent DSM function
parent_dsm <- function(sm) {

  # Check if the matrix is square
  if (ncol(sm) != nrow(sm)) {
    stop("The Resource-Task Matrix must be square.")
  }

  # Multiply matrix S by the transpose of R
  parent_dsm <- sm %*% t(sm)

  return(parent_dsm)
}


#' Risk-based 'Grandparent' Design Structure Matrix (DSM).
#'
#' @param sm Resource-Task Matrix 'S' giving the links (arcs) between resources and tasks.
#' @param rm Risk-Resource Matrix 'R' giving the links (arcs) between risks and resources.
#' @return The function returns the Risk-based 'Grandparent' DSM 'G' giving the number
#' of risks shared between each task.
#' @examples
#' sm <- matrix(c(1, 1, 0, 0, 1, 0, 0, 1, 1), nrow = 3, ncol = 3)
#' rm <- matrix(c(1, 1, 1, 1, 0, 0), nrow = 2, ncol = 3)
#' cat("Resource-Task Matrix:\n")
#' print(sm)
#' cat("\nRisk-Resource Matrix:\n")
#' print(rm)
#' risk_dsm <- grandparent_dsm(sm, rm)
#' cat("\nRisk-based 'Grandparent' DSM:\n")
#' print(risk_dsm)
#' @seealso \url{https://ascelibrary.org/doi/abs/10.1061/AJRUA6.0001041}
#' @export

# Grandparent DSM function
grandparent_dsm <- function(sm, rm) {


  # Check if matrix S is square
  if (ncol(sm) != nrow(sm)) {
    stop("Matrix S must be square.")
  }

  # Check if the matrices can be multiplied
  if (ncol(sm) != ncol(rm)) {
    stop("Number of columns in the Matrix S must be equal to the number
         of columns in Matrix R.")
  }

  # Multiply matrix S by the transpose of R
  tm <- sm %*% t(rm)

  # Multiply matrix T by the transpose of T
  grandparent_dsm <- tm %*% t(tm)

  return(grandparent_dsm)
}
