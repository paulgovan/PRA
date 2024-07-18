#' Planned Value (PV).
#'
#' @param bac Budget at Completion (BAC) (total planned budget).
#' @param schedule Vector of planned work completion (in terms of percentage) at each time period.
#' @param time_period Current time period.
#' @return The function returns the Planned Value (PV) of work completed.
#' @examples
#' # Set the BAC, schedule, and current time period for a toy project.
#' bac <- 100000
#' schedule <- c(0.1, 0.2, 0.4, 0.7, 1.0)
#' time_period <- 3
#'
#' # Calculate the PV and print the results.
#' pv <- pv(bac, schedule, time_period)
#' cat("Planned Value (PV):", pv, "\n")
#' @export
pv <- function(bac, schedule, time_period) {

  pv <- bac * schedule[time_period]
  return(pv)
}

#' Earned Value (EV).
#'
#' @param bac Budget at Completion (BAC) (total planned budget).
#' @param actual_per_complete Actual work completion percentage.
#' @return The function returns the Earned Value (EV) of work completed.
#' @examples
#' # Set the BAC and actual % complete for a toy project.
#' bac <- 100000
#' actual_per_complete <- 0.35
#'
#' # Calculate the EV and print the results.
#' ev <- ev(bac, actual_per_complete)
#' cat("Earned Value (EV):", ev, "\n")
#' @export
ev <- function(bac, actual_per_complete) {

  ev <- bac * actual_per_complete
  return(ev)
}

#' Actual Cost (AC).
#'
#' @param actual_costs Vector of actual costs incurred at each time period.
#' @param time_period Current time period.
#' @return The function returns the Actual Cost (AC) of work completed.
#' @examples
#' # Set the actual costs and current time period for a toy project.
#' actual_costs <- c(9000, 18000, 36000, 70000, 100000)
#' time_period <- 3
#'
#' # Calculate the AC and print the results.
#' ac <- ac(actual_costs, time_period)
#' cat("Actual Cost (AC):", ac, "\n")
#' @export
ac <- function(actual_costs, time_period) {

  ac <- actual_costs[time_period]
  return(ac)
}

#' Schedule Variance (SV).
#'
#' @param ev Earned Value.
#' @param pv Planned Value.
#' @return The function returns the Schedule Variance (SV) of work completed.
#' @examples
#' # Set the BAC, schedule, and current time period for an example project.
#' bac <- 100000
#' schedule <- c(0.1, 0.2, 0.4, 0.7, 1.0)
#' time_period <- 3
#'
#' # Calculate the PV.
#' pv <- pv(bac, schedule, time_period)
#'
#' # Set the actual % complete and calculate the EV.
#' actual_per_complete <- 0.35
#' ev <- ev(bac, actual_per_complete)
#'
#' # Calculate the SV and print the results.
#' sv <- sv(ev, pv)
#' cat("Schedule Variance (SV):", sv, "\n")
#' @export
sv <- function(ev, pv) {

  sv <- ev - pv
  return(sv)
}

#' Cost Variance (CV).
#'
#' @param ev Earned Value.
#' @param ac Actual Cost.
#' @return The function returns the Cost Variance (CV) of work completed.
#' @examples
#' # Set the BAC and actual % complete for an example project.
#' bac <- 100000
#' actual_per_complete <- 0.35
#'
#' # Calcualte the EV
#' ev <- ev(bac, actual_per_complete)
#'
#' # Set the actual costs and current time period and calculate the AC.
#' actual_costs <- c(9000, 18000, 36000, 70000, 100000)
#' time_period <- 3
#' ac <- ac(actual_costs, time_period)
#'
#' # Calculate the CV and print the results.
#' cv <- cv(ev, ac)
#' cat("Cost Variance (CV):", cv, "\n")
#' @export
cv <- function(ev, ac) {

  cv <- ev - ac
  return(cv)
}

#' Schedule Performance Index (SPI).
#'
#' @param ev Earned Value.
#' @param pv Planned Value.
#' @return The function returns the Schedule Performance Index (SPI) of work completed.
#' @examples
#' # Set the BAC, schedule, and current time period for an example project.
#' bac <- 100000
#' schedule <- c(0.1, 0.2, 0.4, 0.7, 1.0)
#' time_period <- 3
#'
#' # Calculate the PV.
#' pv <- pv(bac, schedule, time_period)
#'
#' # Set the actual % complete and calculate the EV.
#' actual_per_complete <- 0.35
#' ev <- ev(bac, actual_per_complete)
#'
#' # Calculate the SPI and print the results.
#' spi <- spi(ev, pv)
#' cat("Schedule Performance Index (SPI):", spi, "\n")
#' @export
spi <- function(ev, pv) {

  spi <- ev / pv
  return(spi)
}

#' Cost Performance Index (CPI).
#'
#' @param ev Earned Value.
#' @param ac Actual Cost.
#' @return The function returns the Cost Performance Index (CPI) of work completed.
#' @examples
#' # Set the BAC and actual % complete for an example project.
#' bac <- 100000
#' actual_per_complete <- 0.35
#'
#' # Calcualte the EV
#' ev <- ev(bac, actual_per_complete)
#'
#' # Set the actual costs and current time period and calculate the AC.
#' actual_costs <- c(9000, 18000, 36000, 70000, 100000)
#' time_period <- 3
#' ac <- ac(actual_costs, time_period)
#'
#' # Calculate the CPI and print the results.
#' cpi <- cpi(ev, ac)
#' cat("Cost Performance Index (CPI):", cpi, "\n")
#' @export
cpi <- function(ev, ac) {

  cpi <- ev / ac
  return(cpi)
}
