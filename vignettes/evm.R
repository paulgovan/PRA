## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(PRA)

## -----------------------------------------------------------------------------
bac <- 100000
schedule <- c(0.1, 0.2, 0.4, 0.7, 1.0)
time_period <- 3

## ----results='asis'-----------------------------------------------------------
pv <- pv(bac, schedule, time_period)
cat("Planned Value (PV):", pv, "\n")

## ----results='asis'-----------------------------------------------------------
actual_per_complete <- 0.35
ev <- ev(bac, actual_per_complete)
cat("Earned Value (EV):", ev, "\n")

## ----results='asis'-----------------------------------------------------------
actual_costs <- c(9000, 18000, 36000)
ac <- ac(actual_costs, time_period)
cat("Actual Cost (AC):", ac, "\n")

## ----results='asis'-----------------------------------------------------------
sv <- sv(ev, pv)
cat("The project is behind schedule because the Schedule Variance (SV) is", sv, "\n")

cv <- cv(ev, ac)
cat("The project is over budget because the Cost Variance (CV) is", cv, "\n")

## ----results='asis'-----------------------------------------------------------
spi <- spi(ev, pv)
cat("The project is behind schedule because the Schedule Performance Index (SPI) is", round(spi, 2), "\n")

cpi <- cpi(ev, ac)
cat("The project is over budget because the Cost Performance Index (CPI) is", round(cpi, 2), "\n")

## ----results='asis'-----------------------------------------------------------
eac <- eac(bac, cpi)
cat("The Estimate at Completion (EAC) is", round(eac, 2), "\n")

## ----warning=FALSE------------------------------------------------------------
# Calculate PV, AC, and EV for time periods 1 to 3
time_period <- c(1, 2, 3)
actual_per_complete <- c(0.05, 0.15, 0.35)
pv <- sapply(1:3, function(t) pv(bac, schedule, t))
ac <- actual_costs
ev <- ev(bac, actual_per_complete)

# Create a data frame for easier plotting
data <- data.frame(
  time_period,
  PV = pv,
  AC = ac,
  EV = ev
)

# Plot PV, AC, and EV over time
p <- ggplot2::ggplot(data, ggplot2::aes(x = time_period)) +
  ggplot2::geom_line(ggplot2::aes(y = PV, color = 'PV'), size = 1) +
  ggplot2::geom_line(ggplot2::aes(y = AC, color = 'AC'), size = 1) +
  ggplot2::geom_line(ggplot2::aes(y = EV, color = 'EV'), size = 1) +
  ggplot2::geom_hline(yintercept = bac, linetype = 'dashed', color = 'blue', size = 1, show.legend = TRUE) +
  ggplot2::geom_hline(yintercept = eac, linetype = 'dotted', color = 'red', size = 1, show.legend = TRUE) +
  ggplot2::labs(title = 'Earned Value',
       x = 'Time Period',
       y = 'Value',
       color = 'Metric') +
  ggplot2::xlim(1, 5) +
  ggplot2::theme_minimal()

# Print the plot
print(p)

