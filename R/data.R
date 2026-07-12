#' Mid-Rise Commercial Building Construction Project
#'
#' A realistic example project used to illustrate the full PRA workflow:
#' schedule/cost uncertainty, earned value management, Bayesian risk inference,
#' and dependency structure analysis. The project comprises six work packages
#' for a mid-rise commercial building. The structure and parameter ranges are
#' adapted from the illustrative construction-project examples in Damnjanovic
#' and Reinschmidt (2020), the reference text this package operationalizes;
#' the values are representative estimates for a project of this type rather
#' than proprietary data from a specific project.
#'
#' @format A named list with the following components:
#' \describe{
#'   \item{task_names}{Character vector of the six work-package names.}
#'   \item{task_distributions}{List of six triangular duration distributions
#'     (weeks), each a list with \code{type = "triangular"} and \code{a}
#'     (optimistic/min), \code{b} (most likely/mode), and \code{c}
#'     (pessimistic/max). Suitable input to [mcs()] and [sensitivity()].}
#'   \item{cor_mat}{6x6 correlation matrix among task durations.}
#'   \item{bac}{Budget at completion (US dollars).}
#'   \item{schedule}{Numeric vector of cumulative planned-value fractions.}
#'   \item{actual_costs}{Numeric vector of per-period actual costs (US dollars).}
#'   \item{time_period}{Integer current reporting period.}
#'   \item{actual_per_complete}{Actual fraction of work complete.}
#'   \item{cause_names}{Character vector of root-cause names for the
#'     schedule-delay risk event.}
#'   \item{cause_probs}{Probabilities that each root cause is present.}
#'   \item{risks_given_causes}{P(delay | cause present) for each cause.}
#'   \item{risks_given_not_causes}{P(delay | cause absent) for each cause.}
#'   \item{observed_causes}{Mid-project observation of each cause
#'     (1 = occurred, 0 = did not occur, \code{NA} = not yet assessed).}
#'   \item{resource_names}{Character vector of the six shared resources.}
#'   \item{resource_task}{Resource-task incidence matrix S (resources x tasks)
#'     for [parent_dsm()] and [grandparent_dsm()].}
#'   \item{risk_names}{Character vector of the three structural risks.}
#'   \item{risk_resource}{Risk-resource incidence matrix R (risks x resources)
#'     for [grandparent_dsm()].}
#' }
#'
#' @references
#' Damnjanovic, Ivan, and Kenneth Reinschmidt. Data Analytics for Engineering
#' and Construction Project Risk Management. Cham, Switzerland: Springer, 2020.
#' \doi{10.1007/978-3-030-14251-3}
#'
#' @examples
#' # Monte Carlo schedule risk (tasks treated as independent)
#' sim <- mcs(10000, building_project$task_distributions)
#' sim$percentiles
#'
#' # Earned value snapshot at the current period
#' bp <- building_project
#' spi(ev(bp$bac, bp$actual_per_complete), pv(bp$bac, bp$schedule, bp$time_period))
"building_project"
