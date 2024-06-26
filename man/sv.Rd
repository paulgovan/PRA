% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/evm.R
\name{sv}
\alias{sv}
\title{Schedule Variance (SV).}
\usage{
sv(ev, pv)
}
\arguments{
\item{ev}{Earned Value.}

\item{pv}{Planned Value.}
}
\value{
The function returns the Schedule Variance (SV) of work completed.
}
\description{
Schedule Variance (SV).
}
\examples{
bac <- 100000
schedule <- c(0.1, 0.2, 0.4, 0.7, 1.0)
time_period <- 3
pv <- pv(bac, schedule, time_period)
actual_per_complete <- 0.35
ev <- ev(bac, actual_per_complete)

sv <- sv(ev, pv)
cat("Schedule Variance (SV):", sv, "\n")
}
